import React from "react";

function MessageList({ messages }) {
  return (
    <div className="message-list">
      {messages.map((msg, idx) => (
        <div
          key={idx}
          className={`message ${msg.sender === "user" ? "user" : "bot"}`}
        >
          <span>{msg.text}</span>
        </div>
      ))}
    </div>
  );
}

export default MessageList;