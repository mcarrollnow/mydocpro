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
