"use client"

import type React from "react"

import { useState, useRef, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Avatar } from "@/components/ui/avatar"
import { ScrollArea } from "@/components/ui/scroll-area"
import { FileText, Send, User, Bot, Paperclip } from 'lucide-react'
import { generateChatResponse } from "@/app/actions/chat-actions"
import { useToast } from "@/components/ui/use-toast"

type Message = {
  id: string
  content: string
  role: "user" | "assistant" | "system"
  timestamp: Date
}

type Document = {
  id: string
  name: string
  type: string
  size: string
  uploadedAt: string
  content: string
  embedding?: number[]
}

export default function ChatInterface() {
  const [input, setInput] = useState("")
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "1",
      content: "Hello! I'm ready to help you with your documents. What would you like to know?",
      role: "assistant",
      timestamp: new Date(),
    },
  ])
  const [isLoading, setIsLoading] = useState(false)
  const scrollAreaRef = useRef<HTMLDivElement>(null)
  const { toast } = useToast()

  useEffect(() => {
    // Scroll to bottom when messages change
    if (scrollAreaRef.current) {
      scrollAreaRef.current.scrollTop = scrollAreaRef.current.scrollHeight
    }
  }, [messages])

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!input.trim() || isLoading) return

    // Add user message
    const userMessage: Message = {
      id: Date.now().toString(),
      content: input,
      role: "user",
      timestamp: new Date(),
    }

    setMessages((prev) => [...prev, userMessage])
    setInput("")
    setIsLoading(true)

    try {
      // Format messages for OpenAI API
      const formattedMessages = messages
        .filter((msg) => msg.role !== "system") // Filter out system messages
        .map((msg) => ({
          role: msg.role,
          content: msg.content,
        }))
        .concat({
          role: "user",
          content: input,
        })

      // Get documents from localStorage to ensure they're available
      const storedDocs: Document[] = JSON.parse(localStorage.getItem('documents') || '[]')
      
      // Create context from stored documents
      const context = storedDocs.length > 0 
        ? storedDocs.map(doc => `Document: ${doc.name}\nContent: ${doc.content}`).join('\n\n')
        : '';
      
      // Call server action with context
      const response = await generateChatResponse(formattedMessages, context)

      if (response.success) {
        const aiMessage: Message = {
          id: (Date.now() + 1).toString(),
          content: response.response || "I'm sorry, I couldn't process that request.",
          role: "assistant",
          timestamp: new Date(),
        }

        setMessages((prev) => [...prev, aiMessage])
      } else {
        throw new Error(response.error)
      }
    } catch (error) {
      console.error("Error in chat:", error)
      toast({
        title: "Error",
        description: "Failed to generate a response. Please try again.",
        variant: "destructive",
      })

      // Add error message
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: "I'm sorry, I encountered an error processing your request. Please try again.",
        role: "assistant",
        timestamp: new Date(),
      }

      setMessages((prev) => [...prev, errorMessage])
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="flex flex-col h-[500px] border border-gray-800 rounded-lg overflow-hidden">
      <div className="flex items-center justify-between p-3 border-b border-gray-800 bg-[#0b0b0b]">
        <div className="flex items-center gap-2">
          <FileText className="h-5 w-5 text-[#ff9166]" />
          <span className="font-medium">Chat with your Documents</span>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="ghost" size="sm" className="text-gray-400 hover:text-white">
            <Paperclip className="h-4 w-4" />
          </Button>
        </div>
      </div>

      <ScrollArea className="flex-1 p-4" ref={scrollAreaRef}>
        <div className="space-y-4">
          {messages.map((message) => (
            <div key={message.id} className={`flex gap-3 ${message.role === "user" ? "justify-end" : "justify-start"}`}>
              {message.role === "assistant" && (
                <Avatar className="h-8 w-8 bg-[#3ad8ff] text-[#0b0b0b]">
                  <Bot className="h-5 w-5" />
                </Avatar>
              )}
              <div
                className={`rounded-lg p-3 max-w-[80%] ${
                  message.role === "user" ? "bg-[#ff9166] text-[#0b0b0b]" : "bg-[#1a1a1a]"
                }`}
              >
                <p>{message.content}</p>
                <p className="text-xs opacity-70 mt-1">
                  {message.timestamp.toLocaleTimeString([], {
                    hour: "2-digit",
                    minute: "2-digit",
                  })}
                </p>
              </div>
              {message.role === "user" && (
                <Avatar className="h-8 w-8 bg-white text-[#0b0b0b]">
                  <User className="h-5 w-5" />
                </Avatar>
              )}
            </div>
          ))}
          {isLoading && (
            <div className="flex gap-3 justify-start">
              <Avatar className="h-8 w-8 bg-[#3ad8ff] text-[#0b0b0b]">
                <Bot className="h-5 w-5" />
              </Avatar>
              <div className="bg-[#1a1a1a] rounded-lg p-3">
                <div className="flex space-x-2">
                  <div
                    className="h-2 w-2 rounded-full bg-[#3ad8ff] animate-bounce"
                    style={{ animationDelay: "0ms" }}
                  ></div>
                  <div
                    className="h-2 w-2 rounded-full bg-[#3ad8ff] animate-bounce"
                    style={{ animationDelay: "150ms" }}
                  ></div>
                  <div
                    className="h-2 w-2 rounded-full bg-[#3ad8ff] animate-bounce"
                    style={{ animationDelay: "300ms" }}
                  ></div>
                </div>
              </div>
            </div>
          )}
        </div>
      </ScrollArea>

      <form onSubmit={handleSend} className="p-3 border-t border-gray-800 bg-[#0b0b0b]">
        <div className="flex gap-2">
          <Input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Ask about your documents..."
            className="bg-[#1a1a1a] border-gray-700 focus-visible:ring-[#3ad8ff]"
          />
          <Button
            type="submit"
            size="icon"
            disabled={!input.trim() || isLoading}
            className="bg-[#3ad8ff] text-[#0b0b0b] hover:bg-[#3ad8ff]/90"
          >
            <Send className="h-4 w-4" />
          </Button>
        </div>
      </form>
    </div>
  )
}