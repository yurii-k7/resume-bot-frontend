import React, { useState } from "react";
import MessageList from "./components/MessageList";
import MessageInput from "./components/MessageInput";
import "./styles/App.css";

function App() {
  const [messages, setMessages] = useState([
    { sender: "bot", text: "Hello! How can I help you today?" },
  ]);

  const handleSend = (text) => {
    setMessages((msgs) => [
      ...msgs,
      { sender: "user", text },
      { sender: "bot", text: `You said: "${text}"` }, // Simple echo bot
    ]);
  };

  return (
    <div className="chat-container">
      <h2>ChatBot for Yurii's resume</h2>
      <MessageList messages={messages} />
      <MessageInput onSend={handleSend} />
    </div>
  );
}

export default App;