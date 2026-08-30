import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") || "";
const GEMINI_API_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

const SYSTEM_PROMPT = `
You are Gym3D AI Coach, a knowledgeable, encouraging, and supportive fitness coach.

Core Guidelines:
1. You are NOT a medical doctor. Never diagnose injuries, prescribe medication, or give medical clearances.
2. For severe pain or injury inquiries, immediately advise consulting a licensed physician or physical therapist.
3. Ground your exercise advice in standard biomechanics and proper form.
4. Keep answers clear, concise, motivating, and actionable. Use bullet points and markdown formatting.
5. Reference the Gym3D 3D model viewer when describing form: "You can inspect this in the 3D viewer."
6. When recommending workouts, structure them with Exercise, Sets, Target Reps, and Rest.
`;

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const { message, conversation_history, user_context, exercise_context } =
      await req.json();

    if (!message) {
      return new Response(JSON.stringify({ error: "Message is required" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Safety filter: check for sharp pain / injury keywords
    const lower = message.toLowerCase();
    const injuryKeywords = ["sharp pain", "torn", "dislocated", "broken", "severe injury", "sprain"];
    const isInjuryQuery = injuryKeywords.some((k) => lower.includes(k));

    if (isInjuryQuery) {
      return new Response(
        JSON.stringify({
          response:
            "⚠️ **Safety Notice**: I detected that you might be experiencing sharp pain or an injury. As an AI fitness coach, I cannot provide medical advice. Please stop exercising immediately and consult a doctor or physical therapist to ensure your safety.",
          suggested_actions: ["Find Physical Therapist", "Gentle Recovery Guidelines"],
        }),
        {
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    // Construct prompt with context
    let contextString = "";
    if (user_context) {
      contextString += `\nUser Profile: Goal: ${user_context.fitness_goal || "General Fitness"}, Level: ${user_context.experience_level || "Intermediate"}, Equipment: ${user_context.available_equipment?.join(", ") || "Full Gym"}.\n`;
    }
    if (exercise_context) {
      contextString += `Current Exercise Context: ${exercise_context.name} (${exercise_context.category}).\n`;
    }

    // Build Gemini request contents
    const contents: any[] = [
      {
        role: "user",
        parts: [{ text: `${SYSTEM_PROMPT}\n${contextString}\nUser: ${message}` }],
      },
    ];

    // Append past messages if provided
    if (Array.isArray(conversation_history)) {
      for (const msg of conversation_history.slice(-6)) {
        contents.push({
          role: msg.role === "user" ? "user" : "model",
          parts: [{ text: msg.content }],
        });
      }
    }

    if (!GEMINI_API_KEY) {
      // Return structured offline fallback response if API key is not yet set
      return new Response(
        JSON.stringify({
          response: `Here is my advice on **${message}**:\n\n` +
            `• **Focus on form**: Maintain a neutral spine and controlled breathing.\n` +
            `• **Progressive overload**: Track your weights each session.\n` +
            `• **Recovery**: Ensure 48 hours of rest between targeting the same muscle group.\n\n` +
            `*You can inspect full 3D biomechanics and muscle activation in the 3D Viewer!*`,
          suggested_actions: ["Show 3D Demonstration", "Add to Today's Routine"],
        }),
        {
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    const geminiRes = await fetch(`${GEMINI_API_URL}?key=${GEMINI_API_KEY}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents,
        generationConfig: {
          maxOutputTokens: 1000,
          temperature: 0.7,
        },
      }),
    });

    const data = await geminiRes.json();
    const reply =
      data.candidates?.[0]?.content?.parts?.[0]?.text ||
      "I'm here to help with your training! Could you clarify your question?";

    return new Response(
      JSON.stringify({
        response: reply,
      }),
      {
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: error.message || "Failed to generate AI coach response",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
});
