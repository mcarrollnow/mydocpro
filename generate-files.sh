#!/bin/bash

# Create directories
mkdir -p app/api/chat
mkdir -p app/api/embedding
mkdir -p app/actions
mkdir -p components/ui
mkdir -p lib

# Create app/page.tsx
cat > app/page.tsx << 'EOL'
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { FileUp, MessageSquare, FileText, Sparkles } from 'lucide-react'
import DocumentUpload from "@/components/document-upload"
import ChatInterface from "@/components/chat-interface"
import RecentDocuments from "@/components/recent-documents"

export default function Home() {
  return (
    <main className="min-h-screen bg-[#0b0b0b] text-white">
      <div className="container mx-auto px-4 py-8">
        <header className="mb-8 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="relative h-10 w-10">
              <div className="absolute h-6 w-6 rounded-full bg-[#3ad8ff] blur-sm"></div>
              <div className="absolute left-4 top-4 h-6 w-6 rounded-full bg-[#ff9166] blur-sm"></div>
              <Sparkles className="relative z-10 h-10 w-10 text-white" />
            </div>
            <h1 className="text-2xl font-bold">DocuMind</h1>
          </div>
          <Button className="bg-[#3ad8ff] text-[#0b0b0b] hover:bg-[#3ad8ff]/90">Get Started</Button>
        </header>

        <div className="mb-8">
          <h2 className="mb-4 text-3xl font-bold">
            Interact with your <span className="text-[#3ad8ff]">documents</span> using{" "}
            <span className="text-[#ff9166]">AI</span>
          </h2>
          <p className="text-lg text-gray-400">
            Upload your documents and chat with an AI that understands their content.
          </p>
        </div>

        <Tabs defaultValue="upload" className="mb-8">
          <TabsList className="grid w-full max-w-md grid-cols-3 bg-[#1a1a1a]">
            <TabsTrigger value="upload" className="data-[state=active]:bg-[#3ad8ff] data-[state=active]:text-[#0b0b0b]">
              <FileUp className="mr-2 h-4 w-4" />
              Upload
            </TabsTrigger>
            <TabsTrigger value="chat" className="data-[state=active]:bg-[#ff9166] data-[state=active]:text-[#0b0b0b]">
              <MessageSquare className="mr-2 h-4 w-4" />
              Chat
            </TabsTrigger>
            <TabsTrigger value="documents" className="data-[state=active]:bg-white data-[state=active]:text-[#0b0b0b]">
              <FileText className="mr-2 h-4 w-4" />
              Documents
            </TabsTrigger>
          </TabsList>
          <TabsContent value="upload">
            <Card className="border-none bg-[#1a1a1a]">
              <CardHeader>
                <CardTitle>Upload Documents</CardTitle>
                <CardDescription className="text-gray-400">
                  Upload your PDFs, Word documents, or text files to interact with them.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <DocumentUpload />
              </CardContent>
            </Card>
          </TabsContent>
          <TabsContent value="chat">
            <Card className="border-none bg-[#1a1a1a]">
              <CardHeader>
                <CardTitle>Chat with your Documents</CardTitle>
                <CardDescription className="text-gray-400">
                  Ask questions about your uploaded documents.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ChatInterface />
              </CardContent>
            </Card>
          </TabsContent>
          <TabsContent value="documents">
            <Card className="border-none bg-[#1a1a1a]">
              <CardHeader>
                <CardTitle>Recent Documents</CardTitle>
                <CardDescription className="text-gray-400">View and manage your uploaded documents.</CardDescription>
              </CardHeader>
              <CardContent>
                <RecentDocuments />
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

        <div className="grid gap-6 md:grid-cols-3">
          <Card className="border-none bg-[#1a1a1a]">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <div className="rounded-full bg-[#3ad8ff] p-2 text-[#0b0b0b]">
                  <FileUp className="h-5 w-5" />
                </div>
                Easy Upload
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-400">
                Drag and drop your documents or browse your files to upload them instantly.
              </p>
            </CardContent>
          </Card>
          <Card className="border-none bg-[#1a1a1a]">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <div className="rounded-full bg-[#ff9166] p-2 text-[#0b0b0b]">
                  <MessageSquare className="h-5 w-5" />
                </div>
                Smart Conversations
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-400">Chat naturally with an AI that understands the context of your documents.</p>
            </CardContent>
          </Card>
          <Card className="border-none bg-[#1a1a1a]">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <div className="rounded-full bg-white p-2 text-[#0b0b0b]">
                  <Sparkles className="h-5 w-5" />
                </div>
                Powerful Insights
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-400">
                Get summaries, answers, and insights from your documents with AI assistance.
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </main>
  )
}
EOL

# Create app/api/chat/route.ts
cat > app/api/chat/route.ts << 'EOL'
import { OpenAI } from "openai"
import { NextResponse } from "next/server"

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
})

export async function POST(request: Request) {
  try {
    const { messages, context } = await request.json()

    if (!messages || !Array.isArray(messages)) {
      return NextResponse.json({ error: "Invalid messages format" }, { status: 400 })
    }

    // Create system message with context
    const systemMessage = {
      role: "system",
      content: `You are an AI assistant that helps users understand their documents. 
      Use the following document context to answer the user's questions. 
      If the answer cannot be found in the documents, say so politely.
      
      Document Context:
      ${context || "No documents provided."}`,
    }

    // Add system message to the beginning of the messages array
    const messagesWithContext = [systemMessage, ...messages]

    // Generate response using OpenAI
    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: messagesWithContext,
      temperature: 0.7,
      max_tokens: 1000,
    })

    return NextResponse.json({
      success: true,
      response: completion.choices[0].message.content,
    })
  } catch (error) {
    console.error("Error in chat API:", error)
    return NextResponse.json(
      {
        success: false,
        error: "Failed to generate response. Please try again.",
      },
      { status: 500 },
    )
  }
}
EOL

# Create app/api/embedding/route.ts
cat > app/api/embedding/route.ts << 'EOL'
import { OpenAI } from "openai"
import { NextResponse } from "next/server"

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
})

export async function POST(request: Request) {
  try {
    const { text } = await request.json()

    if (!text || typeof text !== "string") {
      return NextResponse.json({ error: "Invalid text format" }, { status: 400 })
    }

    const response = await openai.embeddings.create({
      model: "text-embedding-3-small",
      input: text.slice(0, 8000), // Limit to first 8000 chars
    })

    return NextResponse.json({
      success: true,
      embedding: response.data[0].embedding,
    })
  } catch (error) {
    console.error("Error in embedding API:", error)
    return NextResponse.json(
      {
        success: false,
        error: "Failed to generate embedding. Please try again.",
      },
      { status: 500 },
    )
  }
}
EOL

# Create app/actions/document-actions.ts
cat > app/actions/document-actions.ts << 'EOL'
"use server"

import { revalidatePath } from "next/cache"

// Simulated document database
let documents: {
  id: string
  name: string
  type: string
  size: string
  uploadedAt: string
  content: string
  embedding?: number[]
}[] = []

export async function uploadDocument(formData: FormData) {
  try {
    const file = formData.get("file") as File

    if (!file) {
      return { success: false, error: "No file provided" }
    }

    // In a real app, you would store the file in a storage service
    // and extract the text content using a document parsing library
    // For this demo, we'll simulate text extraction
    const fileContent = await simulateTextExtraction(file)

    // Generate embedding using our API route
    let embedding
    try {
      const response = await fetch(`${process.env.VERCEL_URL || "http://localhost:3000"}/api/embedding`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ text: fileContent }),
      })

      const result = await response.json()
      if (result.success) {
        embedding = result.embedding
      }
    } catch (error) {
      console.error("Error calling embedding API:", error)
      // Continue without embedding if API call fails
    }

    // Store document metadata and content
    const newDocument = {
      id: Date.now().toString(),
      name: file.name,
      type: file.name.split(".").pop() || "unknown",
      size: formatFileSize(file.size),
      uploadedAt: "Just now",
      content: fileContent,
      embedding,
    }

    documents.push(newDocument)

    revalidatePath("/")
    return { success: true, document: newDocument }
  } catch (error) {
    console.error("Error uploading document:", error)
    return { success: false, error: "Failed to upload document" }
  }
}

export async function getDocuments() {
  return { documents }
}

export async function deleteDocument(id: string) {
  documents = documents.filter((doc) => doc.id !== id)
  revalidatePath("/")
  return { success: true }
}

// Simulate text extraction from different file types
async function simulateTextExtraction(file: File): Promise<string> {
  // In a real app, you would use libraries like pdf-parse, mammoth, etc.
  const fileType = file.name.split(".").pop()?.toLowerCase()

  // For demo purposes, we'll return dummy content based on file type
  const dummyContent = {
    pdf: `This is extracted content from a PDF file named ${file.name}. It contains information about the project proposal including budget estimates, timeline, and resource allocation.`,
    docx: `This is extracted content from a Word document named ${file.name}. It contains quarterly financial data, revenue projections, and expense reports.`,
    txt: `This is extracted content from a text file named ${file.name}. It contains meeting notes, action items, and decisions made during the team discussion.`,
  }

  return (
    dummyContent[fileType as keyof typeof dummyContent] ||
    `This is extracted content from ${file.name}. The document contains various information that can be queried.`
  )
}

function formatFileSize(bytes: number): string {
  if (bytes < 1024) return bytes + " B"
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
  return (bytes / (1024 * 1024)).toFixed(1) + " MB"
}
EOL

# Create app/actions/chat-actions.ts
cat > app/actions/chat-actions.ts << 'EOL'
"use server"

import { getDocuments } from "./document-actions"

export async function generateChatResponse(messages: { role: string; content: string }[]) {
  try {
    // Get all documents
    const { documents } = await getDocuments()

    if (documents.length === 0) {
      return {
        success: true,
        response: "I don't see any documents uploaded yet. Please upload some documents so I can help you with them.",
      }
    }

    // Create a context from the documents
    const context = documents.map((doc) => `Document: ${doc.name}\nContent: ${doc.content}`).join("\n\n")

    // Call our chat API route
    try {
      const response = await fetch(`${process.env.VERCEL_URL || "http://localhost:3000"}/api/chat`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ messages, context }),
      })

      const result = await response.json()
      if (result.success) {
        return {
          success: true,
          response: result.response,
        }
      } else {
        throw new Error(result.error)
      }
    } catch (error) {
      console.error("Error calling chat API:", error)
      // Fall back to simulated response if API call fails
      return {
        success: true,
        response:
          "I'm having trouble connecting to my AI backend. Here's what I found in your documents: The documents contain information about project proposals, financial data, and meeting notes. If you have specific questions, please try again later.",
      }
    }
  } catch (error) {
    console.error("Error generating chat response:", error)
    return {
      success: false,
      error: "Failed to generate response. Please try again.",
    }
  }
}
EOL

# Create components/document-upload.tsx
cat > components/document-upload.tsx << 'EOL'
"use client"

import type React from "react"

import { useState, useRef } from "react"
import { Button } from "@/components/ui/button"
import { FileUp, File, X, Check } from 'lucide-react'
import { uploadDocument } from "@/app/actions/document-actions"
import { useToast } from "@/components/ui/use-toast"

export default function DocumentUpload() {
  const [isDragging, setIsDragging] = useState(false)
  const [files, setFiles] = useState<File[]>([])
  const [uploading, setUploading] = useState(false)
  const [uploadProgress, setUploadProgress] = useState<Record<string, number>>({})
  const { toast } = useToast()
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(true)
  }

  const handleDragLeave = () => {
    setIsDragging(false)
  }

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)

    if (e.dataTransfer.files) {
      const newFiles = Array.from(e.dataTransfer.files)
      setFiles((prev) => [...prev, ...newFiles])
    }
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      const newFiles = Array.from(e.target.files)
      setFiles((prev) => [...prev, ...newFiles])
    }
  }

  const removeFile = (index: number) => {
    setFiles((prev) => prev.filter((_, i) => i !== index))
  }

  const uploadFiles = async () => {
    if (files.length === 0) return

    setUploading(true)

    // Process each file
    for (const [index, file] of files.entries()) {
      try {
        // Update progress
        setUploadProgress((prev) => ({
          ...prev,
          [file.name]: 10, // Start at 10%
        }))

        // Create FormData
        const formData = new FormData()
        formData.append("file", file)

        // Simulate progress updates
        const progressInterval = setInterval(() => {
          setUploadProgress((prev) => {
            const currentProgress = prev[file.name] || 0
            if (currentProgress < 90) {
              return {
                ...prev,
                [file.name]: currentProgress + Math.floor(Math.random() * 10),
              }
            }
            return prev
          })
        }, 300)

        // Upload the file
        const result = await uploadDocument(formData)

        clearInterval(progressInterval)

        if (result.success) {
          setUploadProgress((prev) => ({
            ...prev,
            [file.name]: 100,
          }))

          toast({
            title: "Document uploaded",
            description: `${file.name} has been processed successfully.`,
          })
        } else {
          throw new Error(result.error)
        }
      } catch (error) {
        console.error(`Error uploading ${file.name}:`, error)
        toast({
          title: "Upload failed",
          description: `Failed to upload ${file.name}. Please try again.`,
          variant: "destructive",
        })

        setUploadProgress((prev) => ({
          ...prev,
          [file.name]: -1, // Use -1 to indicate error
        }))
      }
    }

    // Check if all files are processed
    setTimeout(() => {
      const allDone = Object.values(uploadProgress).every((p) => p === 100 || p === -1)
      if (allDone) {
        setUploading(false)
        setFiles([])
        setUploadProgress({})
      }
    }, 1000)
  }

  return (
    <div className="space-y-4">
      <div
        className={`border-2 border-dashed rounded-lg p-8 text-center transition-colors ${
          isDragging ? "border-[#3ad8ff] bg-[#3ad8ff]/10" : "border-gray-700 hover:border-[#3ad8ff]/50"
        }`}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
      >
        <FileUp className="mx-auto h-12 w-12 text-gray-400 mb-4" />
        <h3 className="text-lg font-medium mb-2">Drag and drop your files here</h3>
        <p className="text-sm text-gray-400 mb-4">Support for PDF, DOCX, TXT, and other text-based documents</p>
        <Button
          variant="outline"
          className="bg-transparent border-[#3ad8ff] text-[#3ad8ff] hover:bg-[#3ad8ff]/10"
          onClick={() => fileInputRef.current?.click()}
        >
          Browse Files
        </Button>
        <input
          ref={fileInputRef}
          id="file-upload"
          type="file"
          multiple
          className="hidden"
          onChange={handleFileChange}
          accept=".pdf,.docx,.txt,.md"
        />
      </div>

      {files.length > 0 && (
        <div className="space-y-4">
          <h3 className="text-lg font-medium">Selected Files</h3>
          <div className="space-y-2">
            {files.map((file, index) => (
              <div key={index} className="flex items-center justify-between bg-[#1a1a1a] p-3 rounded-lg">
                <div className="flex items-center gap-2">
                  <File className="h-5 w-5 text-[#3ad8ff]" />
                  <div>
                    <p className="text-sm font-medium truncate max-w-[200px]">{file.name}</p>
                    <p className="text-xs text-gray-400">{(file.size / 1024).toFixed(1)} KB</p>
                  </div>
                </div>
                {uploading ? (
                  <div className="w-24">
                    {uploadProgress[file.name] === -1 ? (
                      <p className="text-xs text-red-500">Failed</p>
                    ) : (
                      <>
                        <div className="h-2 bg-gray-700 rounded-full overflow-hidden">
                          <div
                            className="h-full bg-[#3ad8ff] transition-all duration-300"
                            style={{ width: `${uploadProgress[file.name] || 0}%` }}
                          />
                        </div>
                        {uploadProgress[file.name] === 100 && <Check className="h-4 w-4 text-green-500 ml-auto mt-1" />}
                      </>
                    )}
                  </div>
                ) : (
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-8 w-8 text-gray-400 hover:text-white hover:bg-[#ff9166]/20"
                    onClick={() => removeFile(index)}
                  >
                    <X className="h-4 w-4" />
                  </Button>
                )}
              </div>
            ))}
          </div>
          {!uploading ? (
            <Button className="w-full bg-[#3ad8ff] text-[#0b0b0b] hover:bg-[#3ad8ff]/90" onClick={uploadFiles}>
              Upload {files.length} {files.length === 1 ? "File" : "Files"}
            </Button>
          ) : (
            <Button disabled className="w-full">
              Uploading...
            </Button>
          )}
        </div>
      )}
    </div>
  )
}
EOL

# Create components/chat-interface.tsx
cat > components/chat-interface.tsx << 'EOL'
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

      // Call server action
      const response = await generateChatResponse(formattedMessages)

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
EOL

# Create components/recent-documents.tsx
cat > components/recent-documents.tsx << 'EOL'
"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { FileText, FileIcon as FilePdf, FileCode, MoreVertical, Download, Trash, Share, Search } from 'lucide-react'
import { getDocuments, deleteDocument } from "@/app/actions/document-actions"
import { useToast } from "@/components/ui/use-toast"

type Document = {
  id: string
  name: string
  type: string
  size: string
  uploadedAt: string
  content?: string
}

export default function RecentDocuments() {
  const [documents, setDocuments] = useState<Document[]>([])
  const [loading, setLoading] = useState(true)
  const { toast } = useToast()

  useEffect(() => {
    async function fetchDocuments() {
      try {
        const result = await getDocuments()
        setDocuments(result.documents)
      } catch (error) {
        console.error("Error fetching documents:", error)
        toast({
          title: "Error",
          description: "Failed to load documents. Please refresh the page.",
          variant: "destructive",
        })
      } finally {
        setLoading(false)
      }
    }

    fetchDocuments()
  }, [toast])

  const getFileIcon = (type: string) => {
    switch (type) {
      case "pdf":
        return <FilePdf className="h-5 w-5 text-[#ff9166]" />
      case "txt":
        return <FileText className="h-5 w-5 text-[#3ad8ff]" />
      default:
        return <FileCode className="h-5 w-5 text-white" />
    }
  }

  const handleDeleteDocument = async (id: string) => {
    try {
      const result = await deleteDocument(id)
      if (result.success) {
        setDocuments(documents.filter((doc) => doc.id !== id))
        toast({
          title: "Document deleted",
          description: "The document has been removed successfully.",
        })
      } else {
        throw new Error("Failed to delete document")
      }
    } catch (error) {
      console.error("Error deleting document:", error)
      toast({
        title: "Error",
        description: "Failed to delete document. Please try again.",
        variant: "destructive",
      })
    }
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center py-12">
        <div className="flex space-x-2">
          <div className="h-3 w-3 rounded-full bg-[#3ad8ff] animate-bounce" style={{ animationDelay: "0ms" }}></div>
          <div className="h-3 w-3 rounded-full bg-[#3ad8ff] animate-bounce" style={{ animationDelay: "150ms" }}></div>
          <div className="h-3 w-3 rounded-full bg-[#3ad8ff] animate-bounce" style={{ animationDelay: "300ms" }}></div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-medium">Your Documents</h3>
        <Button variant="outline" size="sm" className="text-[#3ad8ff] border-[#3ad8ff] hover:bg-[#3ad8ff]/10">
          <Search className="h-4 w-4 mr-2" />
          Search
        </Button>
      </div>

      {documents.length > 0 ? (
        <div className="space-y-2">
          {documents.map((doc) => (
            <div
              key={doc.id}
              className="flex items-center justify-between bg-[#1a1a1a] p-3 rounded-lg hover:bg-[#252525] transition-colors"
            >
              <div className="flex items-center gap-3">
                {getFileIcon(doc.type)}
                <div>
                  <p className="font-medium">{doc.name}</p>
                  <p className="text-xs text-gray-400">
                    {doc.size} • Uploaded {doc.uploadedAt}
                  </p>
                </div>
              </div>
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" size="icon" className="h-8 w-8">
                    <MoreVertical className="h-4 w-4" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  <DropdownMenuItem className="cursor-pointer">
                    <Search className="h-4 w-4 mr-2" />
                    Query
                  </DropdownMenuItem>
                  <DropdownMenuItem className="cursor-pointer">
                    <Download className="h-4 w-4 mr-2" />
                    Download
                  </DropdownMenuItem>
                  <DropdownMenuItem className="cursor-pointer">
                    <Share className="h-4 w-4 mr-2" />
                    Share
                  </DropdownMenuItem>
                  <DropdownMenuItem
                    className="cursor-pointer text-red-500 focus:text-red-500"
                    onClick={() => handleDeleteDocument(doc.id)}
                  >
                    <Trash className="h-4 w-4 mr-2" />
                    Delete
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-8">
          <FileText className="h-12 w-12 text-gray-500 mx-auto mb-4" />
          <h3 className="text-lg font-medium mb-2">No documents found</h3>
          <p className="text-sm text-gray-400 mb-4">Upload documents to start interacting with them</p>
          <Button className="bg-[#3ad8ff] text-[#0b0b0b] hover:bg-[#3ad8ff]/90">Upload Documents</Button>
        </div>
      )}
    </div>
  )
}
EOL

# Create lib/utils.ts
cat > lib/utils.ts << 'EOL'
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
EOL

# Create components/theme-provider.tsx
cat > components/theme-provider.tsx << 'EOL'
"use client"

import * as React from "react"
import { ThemeProvider as NextThemesProvider } from "next-themes"
import { type ThemeProviderProps } from "next-themes"

export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
EOL

# Create app/globals.css
cat > app/globals.css << 'EOL'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 4%;
    --foreground: 0 0% 100%;

    --card: 0 0% 10%;
    --card-foreground: 0 0% 100%;

    --popover: 0 0% 10%;
    --popover-foreground: 0 0% 100%;

    --primary: 190 100% 55%;
    --primary-foreground: 0 0% 4%;

    --secondary: 20 100% 70%;
    --secondary-foreground: 0 0% 4%;

    --muted: 0 0% 15%;
    --muted-foreground: 0 0% 60%;

    --accent: 0 0% 15%;
    --accent-foreground: 0 0% 100%;

    --destructive: 0 100% 50%;
    --destructive-foreground: 0 0% 100%;

    --border: 0 0% 20%;
    --input: 0 0% 20%;
    --ring: 190 100% 55%;

    --radius: 0.5rem;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
EOL

# Create app/layout.tsx
cat > app/layout.tsx << 'EOL'
import type React from "react"
import "./globals.css"
import type { Metadata } from "next"
import { Inter } from 'next/font/google'
import { ThemeProvider } from "@/components/theme-provider"
import { Toaster } from "@/components/ui/toaster"

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "DocuMind - AI Document Interaction",
  description: "Upload and interact with your documents using AI",
}

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <ThemeProvider attribute="class" defaultTheme="dark" enableSystem disableTransitionOnChange>
          {children}
          <Toaster />
        </ThemeProvider>
      </body>
    </html>
  )
}
EOL

# Create UI components
mkdir -p components/ui

# Create components/ui/button.tsx
cat > components/ui/button.tsx << 'EOL'
import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  },
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return <Comp className={cn(buttonVariants({ variant, size, className }))} ref={ref} {...props} />
  },
)
Button.displayName = "Button"

export { Button, buttonVariants }
EOL

# Create components/ui/card.tsx
cat > components/ui/card.tsx << 'EOL'
import * as React from "react"

import { cn } from "@/lib/utils"

const Card = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("rounded-lg border bg-card text-card-foreground shadow-sm", className)} {...props} />
))
Card.displayName = "Card"

const CardHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("flex flex-col space-y-1.5 p-6", className)} {...props} />
  ),
)
CardHeader.displayName = "CardHeader"

const CardTitle = React.forwardRef<HTMLParagraphElement, React.HTMLAttributes<HTMLHeadingElement>>(
  ({ className, ...props }, ref) => (
    <h3 ref={ref} className={cn("text-2xl font-semibold leading-none tracking-tight", className)} {...props} />
  ),
)
CardTitle.displayName = "CardTitle"

const CardDescription = React.forwardRef<HTMLParagraphElement, React.HTMLAttributes<HTMLParagraphElement>>(
  ({ className, ...props }, ref) => (
    <p ref={ref} className={cn("text-sm text-muted-foreground", className)} {...props} />
  ),
)
CardDescription.displayName = "CardDescription"

const CardContent = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />,
)
CardContent.displayName = "CardContent"

const CardFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("flex items-center p-6 pt-0", className)} {...props} />
  ),
)
CardFooter.displayName = "CardFooter"

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent }
EOL

# Create components/ui/input.tsx
cat > components/ui/input.tsx << 'EOL'
import * as React from "react"

import { cn } from "@/lib/utils"

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {}

const Input = React.forwardRef<HTMLInputElement, InputProps>(({ className, type, ...props }, ref) => {
  return (
    <input
      type={type}
      className={cn(
        "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50",
        className,
      )}
      ref={ref}
      {...props}
    />
  )
})
Input.displayName = "Input"

export { Input }
EOL

# Create components/ui/tabs.tsx
cat > components/ui/tabs.tsx << 'EOL'
"use client"

import * as React from "react"
import * as TabsPrimitive from "@radix-ui/react-tabs"

import { cn } from "@/lib/utils"

const Tabs = TabsPrimitive.Root

const TabsList = React.forwardRef<
  React.ElementRef<typeof TabsPrimitive.List>,
  React.ComponentPropsWithoutRef<typeof TabsPrimitive.List>
>(({ className, ...props }, ref) => (
  <TabsPrimitive.List
    ref={ref}
    className={cn(
      "inline-flex h-10 items-center justify-center rounded-md bg-muted p-1 text-muted-foreground",
      className,
    )}
    {...props}
  />
))
TabsList.displayName = TabsPrimitive.List.displayName

const TabsTrigger = React.forwardRef<
  React.ElementRef<typeof TabsPrimitive.Trigger>,
  React.ComponentPropsWithoutRef<typeof TabsPrimitive.Trigger>
>(({ className, ...props }, ref) => (
  <TabsPrimitive.Trigger
    ref={ref}
    className={cn(
      "inline-flex items-center justify-center whitespace-nowrap rounded-sm px-3 py-1.5 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow-sm",
      className,
    )}
    {...props}
  />
))
TabsTrigger.displayName = TabsPrimitive.Trigger.displayName

const TabsContent = React.forwardRef<
  React.ElementRef<typeof TabsPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof TabsPrimitive.Content>
>(({ className, ...props }, ref) => (
  <TabsPrimitive.Content
    ref={ref}
    className={cn(
      "mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
      className,
    )}
    {...props}
  />
))
TabsContent.displayName = TabsPrimitive.Content.displayName

export { Tabs, TabsList, TabsTrigger, TabsContent }
EOL

# Create components/ui/avatar.tsx
cat > components/ui/avatar.tsx << 'EOL'
"use client"

import * as React from "react"
import * as AvatarPrimitive from "@radix-ui/react-avatar"

import { cn } from "@/lib/utils"

const Avatar = React.forwardRef<
  React.ElementRef<typeof AvatarPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Root>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Root
    ref={ref}
    className={cn("relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full", className)}
    {...props}
  />
))
Avatar.displayName = AvatarPrimitive.Root.displayName

const AvatarImage = React.forwardRef<
  React.ElementRef<typeof AvatarPrimitive.Image>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Image>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Image ref={ref} className={cn("aspect-square h-full w-full", className)} {...props} />
))
AvatarImage.displayName = AvatarPrimitive.Image.displayName

const AvatarFallback = React.forwardRef<
  React.ElementRef<typeof AvatarPrimitive.Fallback>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Fallback>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Fallback
    ref={ref}
    className={cn("flex h-full w-full items-center justify-center rounded-full bg-muted", className)}
    {...props}
  />
))
AvatarFallback.displayName = AvatarPrimitive.Fallback.displayName

export { Avatar, AvatarImage, AvatarFallback }
EOL

# Create components/ui/scroll-area.tsx
cat > components/ui/scroll-area.tsx << 'EOL'
"use client"

import * as React from "react"
import * as ScrollAreaPrimitive from "@radix-ui/react-scroll-area"

import { cn } from "@/lib/utils"

const ScrollArea = React.forwardRef<
  React.ElementRef<typeof ScrollAreaPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof ScrollAreaPrimitive.Root>
>(({ className, children, ...props }, ref) => (
  <ScrollAreaPrimitive.Root ref={ref} className={cn("relative overflow-hidden", className)} {...props}>
    <ScrollAreaPrimitive.Viewport className="h-full w-full rounded-[inherit]">{children}</ScrollAreaPrimitive.Viewport>
    <ScrollBar />
    <ScrollAreaPrimitive.Corner />
  </ScrollAreaPrimitive.Root>
))
ScrollArea.displayName = ScrollAreaPrimitive.Root.displayName

const ScrollBar = React.forwardRef<
  React.ElementRef<typeof ScrollAreaPrimitive.ScrollAreaScrollbar>,
  React.ComponentPropsWithoutRef<typeof ScrollAreaPrimitive.ScrollAreaScrollbar>
>(({ className, orientation = "vertical", ...props }, ref) => (
  <ScrollAreaPrimitive.ScrollAreaScrollbar
    ref={ref}
    orientation={orientation}
    className={cn(
      "flex touch-none select-none transition-colors",
      orientation === "vertical" && "h-full w-2.5 border-l border-l-transparent p-[1px]",
      orientation === "horizontal" && "h-2.5 border-t border-t-transparent p-[1px]",
      className,
    )}
    {...props}
  >
    <ScrollAreaPrimitive.ScrollAreaThumb className="relative flex-1 rounded-full bg-border" />
  </ScrollAreaPrimitive.ScrollAreaScrollbar>
))
ScrollBar.displayName = ScrollAreaPrimitive.ScrollAreaScrollbar.displayName

export { ScrollArea, ScrollBar }
EOL

# Create components/ui/dropdown-menu.tsx
cat > components/ui/dropdown-menu.tsx << 'EOL'
"use client"

import * as React from "react"
import * as DropdownMenuPrimitive from "@radix-ui/react-dropdown-menu"
import { Check, ChevronRight, Circle } from 'lucide-react'

import { cn } from "@/lib/utils"

const DropdownMenu = DropdownMenuPrimitive.Root

const DropdownMenuTrigger = DropdownMenuPrimitive.Trigger

const DropdownMenuGroup = DropdownMenuPrimitive.Group

const DropdownMenuPortal = DropdownMenuPrimitive.Portal

const DropdownMenuSub = DropdownMenuPrimitive.Sub

const DropdownMenuRadioGroup = DropdownMenuPrimitive.RadioGroup

const DropdownMenuSubTrigger = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.SubTrigger>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.SubTrigger> & {
    inset?: boolean
  }
>(({ className, inset, children, ...props }, ref) => (
  <DropdownMenuPrimitive.SubTrigger
    ref={ref}
    className={cn(
      "flex cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none focus:bg-accent data-[state=open]:bg-accent",
      inset && "pl-8",
      className,
    )}
    {...props}
  >
    {children}
    <ChevronRight className="ml-auto h-4 w-4" />
  </DropdownMenuPrimitive.SubTrigger>
))
DropdownMenuSubTrigger.displayName = DropdownMenuPrimitive.SubTrigger.displayName

const DropdownMenuSubContent = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.SubContent>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.SubContent>
>(({ className, ...props }, ref) => (
  <DropdownMenuPrimitive.SubContent
    ref={ref}
    className={cn(
      "z-50 min-w-[8rem] overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-lg data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
      className,
    )}
    {...props}
  />
))
DropdownMenuSubContent.displayName = DropdownMenuPrimitive.SubContent.displayName

const DropdownMenuContent = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Content>
>(({ className, sideOffset = 4, ...props }, ref) => (
  <DropdownMenuPrimitive.Portal>
    <DropdownMenuPrimitive.Content
      ref={ref}
      sideOffset={sideOffset}
      className={cn(
        "z-50 min-w-[8rem] overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
        className,
      )}
      {...props}
    />
  </DropdownMenuPrimitive.Portal>
))
DropdownMenuContent.displayName = DropdownMenuPrimitive.Content.displayName

const DropdownMenuItem = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.Item>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Item> & {
    inset?: boolean
  }
>(({ className, inset, ...props }, ref) => (
  <DropdownMenuPrimitive.Item
    ref={ref}
    className={cn(
      "relative flex cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
      inset && "pl-8",
      className,
    )}
    {...props}
  />
))
DropdownMenuItem.displayName = DropdownMenuPrimitive.Item.displayName

const DropdownMenuCheckboxItem = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.CheckboxItem>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.CheckboxItem>
>(({ className, children, checked, ...props }, ref) => (
  <DropdownMenuPrimitive.CheckboxItem
    ref={ref}
    className={cn(
      "relative flex cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none transition-colors focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
      className,
    )}
    checked={checked}
    {...props}
  >
    <span className="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
      <DropdownMenuPrimitive.ItemIndicator>
        <Check className="h-4 w-4" />
      </DropdownMenuPrimitive.ItemIndicator>
    </span>
    {children}
  </DropdownMenuPrimitive.CheckboxItem>
))
DropdownMenuCheckboxItem.displayName = DropdownMenuPrimitive.CheckboxItem.displayName

const DropdownMenuRadioItem = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.RadioItem>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.RadioItem>
>(({ className, children, ...props }, ref) => (
  <DropdownMenuPrimitive.RadioItem
    ref={ref}
    className={cn(
      "relative flex cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none transition-colors focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
      className,
    )}
    {...props}
  >
    <span className="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
      <DropdownMenuPrimitive.ItemIndicator>
        <Circle className="h-2 w-2 fill-current" />
      </DropdownMenuPrimitive.ItemIndicator>
    </span>
    {children}
  </DropdownMenuPrimitive.RadioItem>
))
DropdownMenuRadioItem.displayName = DropdownMenuPrimitive.RadioItem.displayName

const DropdownMenuLabel = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.Label>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Label> & {
    inset?: boolean
  }
>(({ className, inset, ...props }, ref) => (
  <DropdownMenuPrimitive.Label
    ref={ref}
    className={cn("px-2 py-1.5 text-sm font-semibold", inset && "pl-8", className)}
    {...props}
  />
))
DropdownMenuLabel.displayName = DropdownMenuPrimitive.Label.displayName

const DropdownMenuSeparator = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.Separator>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Separator>
>(({ className, ...props }, ref) => (
  <DropdownMenuPrimitive.Separator ref={ref} className={cn("-mx-1 my-1 h-px bg-muted", className)} {...props} />
))
DropdownMenuSeparator.displayName = DropdownMenuPrimitive.Separator.displayName

const DropdownMenuShortcut = ({ className, ...props }: React.HTMLAttributes<HTMLSpanElement>) => {
  return <span className={cn("ml-auto text-xs tracking-widest opacity-60", className)} {...props} />
}
DropdownMenuShortcut.displayName = "DropdownMenuShortcut"

export {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuCheckboxItem,
  DropdownMenuRadioItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuShortcut,
  DropdownMenuGroup,
  DropdownMenuPortal,
  DropdownMenuSub,
  DropdownMenuSubContent,
  DropdownMenuSubTrigger,
  DropdownMenuRadioGroup,
}
EOL

# Create components/ui/toast.tsx
cat > components/ui/toast.tsx << 'EOL'
import * as React from "react"
import * as ToastPrimitives from "@radix-ui/react-toast"
import { cva, type VariantProps } from "class-variance-authority"
import { X } from 'lucide-react'

import { cn } from "@/lib/utils"

const ToastProvider = ToastPrimitives.Provider

const ToastViewport = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Viewport>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Viewport>
>(({ className, ...props }, ref) => (
  <ToastPrimitives.Viewport
    ref={ref}
    className={cn(
      "fixed top-0 z-[100] flex max-h-screen w-full flex-col-reverse p-4 sm:bottom-0 sm:right-0 sm:top-auto sm:flex-col md:max-w-[420px]",
      className,
    )}
    {...props}
  />
))
ToastViewport.displayName = ToastPrimitives.Viewport.displayName

const toastVariants = cva(
  "group pointer-events-auto relative flex w-full items-center justify-between space-x-4 overflow-hidden rounded-md border p-6 pr-8 shadow-lg transition-all data-[swipe=cancel]:translate-x-0 data-[swipe=end]:translate-x-[var(--radix-toast-swipe-end-x)] data-[swipe=move]:translate-x-[var(--radix-toast-swipe-move-x)] data-[swipe=move]:transition-none data-[state=open]:animate-in data-[state=closed]:animate-out data-[swipe=end]:animate-out data-[state=closed]:fade-out-80 data-[state=closed]:slide-out-to-right-full data-[state=open]:slide-in-from-top-full data-[state=open]:sm:slide-in-from-bottom-full",
  {
    variants: {
      variant: {
        default: "border bg-[#1a1a1a] text-white",
        destructive: "destructive group border-red-500 bg-red-500/20 text-red-300",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  },
)

const Toast = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Root>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Root> & VariantProps<typeof toastVariants>
>(({ className, variant, ...props }, ref) => {
  return <ToastPrimitives.Root ref={ref} className={cn(toastVariants({ variant }), className)} {...props} />
})
Toast.displayName = ToastPrimitives.Root.displayName

const ToastAction = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Action>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Action>
>(({ className, ...props }, ref) => (
  <ToastPrimitives.Action
    ref={ref}
    className={cn(
      "inline-flex h-8 shrink-0 items-center justify-center rounded-md border bg-transparent px-3 text-sm font-medium ring-offset-background transition-colors hover:bg-secondary focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 group-[.destructive]:border-muted/40 group-[.destructive]:hover:border-destructive/30 group-[.destructive]:hover:bg-destructive group-[.destructive]:hover:text-destructive-foreground group-[.destructive]:focus:ring-destructive",
      className,
    )}
    {...props}
  />
))
ToastAction.displayName = ToastPrimitives.Action.displayName

const ToastClose = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Close>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Close>
>(({ className, ...props }, ref) => (
  <ToastPrimitives.Close
    ref={ref}
    className={cn(
      "absolute right-2 top-2 rounded-md p-1 text-foreground/50 opacity-0 transition-opacity hover:text-foreground focus:opacity-100 focus:outline-none focus:ring-2 group-hover:opacity-100 group-[.destructive]:text-red-300 group-[.destructive]:hover:text-red-50 group-[.destructive]:focus:ring-red-400 group-[.destructive]:focus:ring-offset-red-600",
      className,
    )}
    toast-close=""
    {...props}
  >
    <X className="h-4 w-4" />
  </ToastPrimitives.Close>
))
ToastClose.displayName = ToastPrimitives.Close.displayName

const ToastTitle = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Title>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Title>
>(({ className, ...props }, ref) => (
  <ToastPrimitives.Title ref={ref} className={cn("text-sm font-semibold", className)} {...props} />
))
ToastTitle.displayName = ToastPrimitives.Title.displayName

const ToastDescription = React.forwardRef<
  React.ElementRef<typeof ToastPrimitives.Description>,
  React.ComponentPropsWithoutRef<typeof ToastPrimitives.Description>
>(({ className, ...props }, ref) => (
  <ToastPrimitives.Description ref={ref} className={cn("text-sm opacity-90", className)} {...props} />
))
ToastDescription.displayName = ToastPrimitives.Description.displayName

type ToastProps = React.ComponentPropsWithoutRef<typeof Toast>

type ToastActionElement = React.ReactElement<typeof ToastAction>

export {
  type ToastProps,
  type ToastActionElement,
  ToastProvider,
  ToastViewport,
  Toast,
  ToastTitle,
  ToastDescription,
  ToastClose,
  ToastAction,
}
EOL

# Create components/ui/use-toast.ts
cat > components/ui/use-toast.ts << 'EOL'
"use client"

import * as React from "react"

import type { ToastActionElement, ToastProps } from "@/components/ui/toast"

const TOAST_LIMIT = 5
const TOAST_REMOVE_DELAY = 5000

type ToasterToast = ToastProps & {
  id: string
  title?: React.ReactNode
  description?: React.ReactNode
  action?: ToastActionElement
}

const actionTypes = {
  ADD_TOAST: "ADD_TOAST",
  UPDATE_TOAST: "UPDATE_TOAST",
  DISMISS_TOAST: "DISMISS_TOAST",
  REMOVE_TOAST: "REMOVE_TOAST",
} as const

let count = 0

function genId() {
  count = (count + 1) % Number.MAX_SAFE_INTEGER
  return count.toString()
}

type ActionType = typeof actionTypes

type Action =
  | {
      type: ActionType["ADD_TOAST"]
      toast: ToasterToast
    }
  | {
      type: ActionType["UPDATE_TOAST"]
      toast: Partial<ToasterToast>
    }
  | {
      type: ActionType["DISMISS_TOAST"]
      toastId?: string
    }
  | {
      type: ActionType["REMOVE_TOAST"]
      toastId?: string
    }

interface State {
  toasts: ToasterToast[]
}

const toastTimeouts = new Map<string, ReturnType<typeof setTimeout>>()

const reducer = (state: State, action: Action): State => {
  switch (action.type) {
    case "ADD_TOAST":
      return {
        ...state,
        toasts: [action.toast, ...state.toasts].slice(0, TOAST_LIMIT),
      }

    case "UPDATE_TOAST":
      return {
        ...state,
        toasts: state.toasts.map((t) => (t.id === action.toast.id ? { ...t, ...action.toast } : t)),
      }

    case "DISMISS_TOAST": {
      const { toastId } = action

      // ! Side effects ! - This could be extracted into a dismissToast() action,
      // but I'll keep it here for simplicity
      if (toastId) {
        if (toastTimeouts.has(toastId)) {
          clearTimeout(toastTimeouts.get(toastId))
          toastTimeouts.delete(toastId)
        }
      } else {
        for (const [id, timeout] of toastTimeouts.entries()) {
          clearTimeout(timeout)
          toastTimeouts.delete(id)
        }
      }

      return {
        ...state,
        toasts: state.toasts.map((t) =>
          t.id === toastId || toastId === undefined
            ? {
                ...t,
                open: false,
              }
            : t,
        ),
      }
    }
    case "REMOVE_TOAST":
      if (action.toastId === undefined) {
        return {
          ...state,
          toasts: [],
        }
      }
      return {
        ...state,
        toasts: state.toasts.filter((t) => t.id !== action.toastId),
      }
  }
}

const listeners: Array<(state: State) => void> = []

let memoryState: State = { toasts: [] }

function dispatch(action: Action) {
  memoryState = reducer(memoryState, action)
  listeners.forEach((listener) => {
    listener(memoryState)
  })
}

type Toast = Omit<ToasterToast, "id">

function toast({ ...props }: Toast) {
  const id = genId()

  const update = (props: ToasterToast) =>
    dispatch({
      type: "UPDATE_TOAST",
      toast: { ...props, id },
    })
  const dismiss = () => dispatch({ type: "DISMISS_TOAST", toastId: id })

  dispatch({
    type: "ADD_TOAST",
    toast: {
      ...props,
      id,
      open: true,
    },
  })

  return {
    id: id,
    close: dismiss,
    update: update,
  }
}

type UpdateFn = (props: ToasterToast) => void

const STATE_CHANGE_EVENT = "TOASTS_STATE_CHANGE"

type EmitToast = (toast: Toast) => {
  id: string
  close: () => void
  update: UpdateFn
}

export function useToast() {
  const [state, setState] = React.useState<State>(memoryState)

  React.useEffect(() => {
    listeners.push(setState)
    return () => {
      const index = listeners.indexOf(setState)
      if (index > -1) {
        listeners.splice(index, 1)
      }
    }
  }, [setState])

  return {
    ...state,
    toast: toast as EmitToast,
    dismiss: (toastId?: string) => dispatch({ type: "DISMISS_TOAST", toastId }),
    remove: (toastId?: string) => dispatch({ type: "REMOVE_TOAST", toastId }),
  }
}

export function useToaster() {
  const [state, setState] = React.useState<State>(memoryState)

  React.useEffect(() => {
    listeners.push(setState)
    return () => {
      const index = listeners.indexOf(setState)
      if (index > -1) {
        listeners.splice(index, 1)
      }
    }
  }, [setState])

  return {
    ...state,
    toast: toast as EmitToast,
    dismiss: (toastId?: string) => dispatch({ type: "DISMISS_TOAST", toastId }),
    remove: (toastId?: string) => dispatch({ type: "REMOVE_TOAST", toastId }),
  }
}
EOL

# Create components/ui/toaster.tsx
cat > components/ui/toaster.tsx << 'EOL'
"use client"

import { Toast, ToastClose, ToastDescription, ToastProvider, ToastTitle, ToastViewport } from "@/components/ui/toast"
import { useToast } from "@/components/ui/use-toast"

export function Toaster() {
  const { toasts } = useToast()

  return (
    <ToastProvider>
      {toasts.map(({ id, title, description, action, ...props }) => (
        <Toast key={id} {...props}>
          <div className="grid gap-1">
            {title && <ToastTitle>{title}</ToastTitle>}
            {description && <ToastDescription>{description}</ToastDescription>}
          </div>
          {action}
          <ToastClose />
        </Toast>
      ))}
      <ToastViewport />
    </ToastProvider>
  )
}
EOL

echo "All files have been created successfully!"
echo "Next steps:"
echo "1. Install required dependencies:"
echo "   npm install openai lucide-react @radix-ui/react-tabs @radix-ui/react-dropdown-menu @radix-ui/react-scroll-area @radix-ui/react-toast @radix-ui/react-avatar next-themes clsx tailwind-merge class-variance-authority"
echo "2. Run the development server:"
echo "   npm run dev"
echo "3. Commit and push to your repository:"
echo "   git add ."
echo "   git commit -m \"Add document AI application code\""
echo "   git push origin main"