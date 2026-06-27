import { onRequest } from "firebase-functions/v2/https";
import { info, error as logError } from "firebase-functions/logger";
import OpenAI from "openai";

export const interpretTarot = onRequest(
  {
    region: "us-central1",
    cors: true,
    timeoutSeconds: 60,
    memory: "512MiB",
    secrets: ["OPENAI_API_KEY"],
  },
  async (req, res) => {
    info("interpretTarot called", {
      method: req.method,
      hasBody: !!req.body,
    });

    try {
      if (req.method !== "POST") {
        info("Rejected non-POST request");
        res.status(405).json({ error: "Method not allowed" });
        return;
      }

      const apiKeyExists = !!process.env.OPENAI_API_KEY;
      info("OpenAI key available", { apiKeyExists });

      if (!apiKeyExists) {
        res.status(500).json({ error: "OPENAI_API_KEY is not configured" });
        return;
      }

      const {
        question,
        cards,
        spreadCount,
        notes,
        rune,
        iChingHexagramNumber,
        iChingChangingLines,
      } = req.body ?? {};

      info("Parsed request", {
        hasQuestion: !!question,
        cardCount: Array.isArray(cards) ? cards.length : null,
        spreadCount,
        hasNotes: !!notes,
        hasRune: !!rune,
        hasIChingHexagramNumber: typeof iChingHexagramNumber === "number",
        iChingChangingLineCount: Array.isArray(iChingChangingLines)
          ? iChingChangingLines.length
          : null,
      });

      if (
        !question ||
        typeof question !== "string" ||
        !Array.isArray(cards) ||
        cards.length === 0
      ) {
        res.status(400).json({
          error: "Missing required fields: question and cards",
        });
        return;
      }

      const sanitizedCards = cards.filter((card) => {
        return typeof card === "string" && card.trim().length > 0;
      });

      if (sanitizedCards.length === 0) {
        res.status(400).json({
          error: "cards must contain at least one non-empty string",
        });
        return;
      }

      const sanitizedSpreadCount =
        typeof spreadCount === "number" && spreadCount > 0
          ? spreadCount
          : sanitizedCards.length;

      const sanitizedNotes =
        typeof notes === "string" && notes.trim().length > 0
          ? notes.trim()
          : null;

      const sanitizedRune =
        typeof rune === "string" && rune.trim().length > 0
          ? rune.trim()
          : null;

      const sanitizedHexagramNumber =
        typeof iChingHexagramNumber === "number" &&
        Number.isInteger(iChingHexagramNumber) &&
        iChingHexagramNumber >= 1 &&
        iChingHexagramNumber <= 64
          ? iChingHexagramNumber
          : null;

      const sanitizedChangingLines = Array.isArray(iChingChangingLines)
        ? iChingChangingLines.filter((line) => {
            return (
              typeof line === "number" &&
              Number.isInteger(line) &&
              line >= 1 &&
              line <= 6
            );
          })
        : [];

      const openai = new OpenAI({
        apiKey: process.env.OPENAI_API_KEY,
      });

      const systemPrompt = `
You are an intuitive but grounded divination interpreter. Act as a critical analyst synthesizing symbolic systems into a concrete answer.

The user's reading may contain:
- tarot cards
- a rune
- an I Ching hexagram number
- I Ching changing lines

Interpret only the systems that are actually present. Do not invent missing symbols.

Rules:
- Directly answer the user's question.
- If the question naturally calls for yes or no, begin the summary with a direct yes or no.
- Prioritize decisive indicators over vague symbolism.
- If an I Ching hexagram is present, treat the hexagram number as the authoritative identification of the hexagram.
- If changing lines are present, interpret them as line numbers 1 through 6, counted from the bottom line upward.
- Synthesize overlaps between tarot, rune, and I Ching when more than one system is present.
- Avoid empty mysticism, hedging, or giving every possible interpretation.
- Be clear, concrete, and decisive.
- The summary must be 6 paragraphs or more.

For cardByCard:
- Include one concise interpretation for each tarot card.
- If a rune is present, include one separate concise interpretation entry for the rune.
- If an I Ching hexagram is present, include one separate concise interpretation entry for the hexagram, mentioning changing lines when provided.

Return ONLY valid JSON with this exact shape:
{
  "summary": "string",
  "cardByCard": ["string"],
  "advice": ["string"],
  "journalPrompts": ["string"]
}
`.trim();

      const userPrompt = `
Question:
${question}

Tarot cards (${sanitizedSpreadCount}):
${sanitizedCards.map((c, i) => `${i + 1}. ${c}`).join("\n")}

Rune:
${sanitizedRune ?? "None"}

I Ching hexagram number:
${sanitizedHexagramNumber ?? "None"}

I Ching changing lines:
${sanitizedChangingLines.length > 0 ? sanitizedChangingLines.join(", ") : "None"}

Notes:
${sanitizedNotes ?? "None"}
`.trim();

      info("Calling OpenAI", {
        model: "gpt-4.1-mini",
        hasRune: !!sanitizedRune,
        hasHexagram: sanitizedHexagramNumber !== null,
        changingLineCount: sanitizedChangingLines.length,
      });

      const response = await openai.responses.create({
        model: "gpt-4.1-mini",
        input: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ],
        text: {
          format: {
            type: "json_schema",
            name: "tarot_reading",
            schema: {
              type: "object",
              additionalProperties: false,
              properties: {
                summary: { type: "string" },
                cardByCard: {
                  type: "array",
                  items: { type: "string" },
                },
                advice: {
                  type: "array",
                  items: { type: "string" },
                },
                journalPrompts: {
                  type: "array",
                  items: { type: "string" },
                },
              },
              required: ["summary", "cardByCard", "advice", "journalPrompts"],
            },
          },
        },
      });

      info("OpenAI returned response", {
        hasOutputText: !!response.output_text,
      });

      if (!response.output_text) {
        res.status(500).json({ error: "No output returned from model" });
        return;
      }

      const parsed = JSON.parse(response.output_text);

      info("Returning success", {
        summaryLength:
          typeof parsed?.summary === "string" ? parsed.summary.length : 0,
        cardByCardCount: Array.isArray(parsed?.cardByCard)
          ? parsed.cardByCard.length
          : 0,
        adviceCount: Array.isArray(parsed?.advice) ? parsed.advice.length : 0,
        journalPromptCount: Array.isArray(parsed?.journalPrompts)
          ? parsed.journalPrompts.length
          : 0,
      });

      res.status(200).json(parsed);
    } catch (err) {
      logError("interpretTarot failed", {
        message: err?.message,
        stack: err?.stack,
        name: err?.name,
      });

      res.status(500).json({
        error: err?.message ?? "Unknown server error",
      });
    }
  }
);