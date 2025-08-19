class LegislativePrompt {
  final String documentName;
  final String documentText;
  final List<List<String>> chatHistory;

  LegislativePrompt({
    required this.documentName,
    required this.documentText,
    required this.chatHistory,
  });

  /// Formats the list of [ChatMessage] objects into a plain text,
  /// script-like format for the model to easily understand.
  String _formatChatHistory() {
    // Using a StringBuffer is more efficient for building strings in a loop.
    final buffer = StringBuffer();
    for (final message in chatHistory) {
      buffer.writeln('${message[0]}: ${message[1]}'); //[{"user": "what does this mean?"}, {"chatbot": "explanation..."}
    }
    return buffer.toString();
  }

  /// Builds the final, complete prompt string to be sent to the Gemini API.
  ///
  /// It interpolates the document name, text, and formatted chat history
  /// into the main system prompt template.
  String build() {
    final formattedHistory = _formatChatHistory();

    // Using a multi-line string for the template makes it easy to read and maintain.
    String value = '''
# SYSTEM PROMPT: AI LEGISLATIVE ANALYST

## 1. YOUR ROLE AND TASK
You are an expert AI legislative analyst. Your purpose is to help a user understand a legislative bill currently going through the U.S. Congress. You must analyze the bill's contents and explain its potential real-world impact.

## 2. KNOWLEDGE SOURCES & METHODOLOGY
Your analysis must be a synthesis of two sources:
1.  **The Bill's Text:** The primary source of truth, provided in the 'SOURCE DOCUMENT' section.
2.  **External Knowledge:** Your internal knowledge of current U.S. law, regulations, and public policy.

To answer a question, first identify the relevant section(s) of the bill. Then, use your external knowledge to explain the context or potential effects of those provisions.

## 3. RULES AND GUIDELINES
- **Ground Your Analysis:** When explaining an impact, always tie it back to a specific provision in the bill if possible.
- **Distinguish Fact from Analysis:** Clearly differentiate between what the bill explicitly states and what are potential or likely impacts. Use phrases like "This bill proposes..." for facts, and "This could likely impact..." for analysis.
- **Be Concise and On-Topic:** Provide direct answers to the user's question. Avoid irrelevant details or overly long explanations.
- **Use Chat History:** Refer to the 'CONVERSATION HISTORY' to maintain context for follow-up questions.

---

## 4. SOURCE DOCUMENT
DOCUMENT NAME: $documentName

$documentText

---

## 5. CONVERSATION HISTORY & CURRENT QUESTION
${formattedHistory}Assistant:
''';
//print(value);
return value;
  }
}

/*
Legislation Context: Look into Gemini File API for uploading the text/pdf, getting a URI, and referencing it in generateContent
Ideas:
  Context costs money. Format the referenced bill and entire chat history into the prompt. As JSON?.
  
  Prompt Structure:
  1: System/Document Context: This can be a text block at the start, instructing the model on its role and providing the document.
  2: Chat History: The JSON list of Content objects from the conversation so far.
  3: New User Question: The final Content object in the list, representing the user's latest query.

  Example:

  "You are a chatbot for a user asking questions about a current legislation going through congress, the specific bill is ${bill.name}. Here is the full text:
  ...
  Use this chat history for context:"
  [
  {
    "role": "user",
    "parts": [
      {
        "text": "What is the capital of France?"
      }
    ]
  },
  {
    "role": "model",
    "parts": [
      {
        "text": "The capital of France is Paris."
      }
    ]
  },
  {
    "role": "user",
    "parts": [
      {
        "text": "What's the main river that flows through it?"
      }
    ]
  }
]

Given the above document and chat context, respond to the final user message: ${User.question}


*/