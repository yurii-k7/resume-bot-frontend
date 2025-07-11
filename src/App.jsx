import React, { useState } from "react";
import MessageList from "./components/MessageList";
import MessageInput from "./components/MessageInput";
import "./styles/App.css";

function App() {
  const [messages, setMessages] = useState([
    { sender: "bot", text: "Hello! How can I help you today?" },
  ]);
  const [loading, setLoading] = useState(false);

  const handleSend = async (text) => {
    setMessages((msgs) => [
      ...msgs,
      { sender: "user", text },
    ]);
    setLoading(true);
    try {
      const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:8081";
      const response = await fetch(`${apiUrl}/question`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ question: text }),
      });
      const data = await response.json();
      setMessages((msgs) => [
        ...msgs,
        { sender: "bot", text: data.answer || "Sorry, no answer received." },
      ]);
    } catch (error) {
      setMessages((msgs) => [
        ...msgs,
        { sender: "bot", text: "Error: Could not get response from server." },
      ]);
      console.log("Error fetching response:", error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="chat-container">
      <h2>ChatBot for Yurii's resume</h2>
      <MessageList messages={messages} />
      <MessageInput onSend={handleSend} disabled={loading} />
      {loading && <div className="loading">Bot is typing...</div>}
    </div>
  );
}

export default App;