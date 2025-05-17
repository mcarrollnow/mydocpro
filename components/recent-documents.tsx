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
  embedding?: number[]
}

export default function RecentDocuments() {
  const [documents, setDocuments] = useState<Document[]>([])
  const [loading, setLoading] = useState(true)
  const { toast } = useToast()

  useEffect(() => {
    async function fetchDocuments() {
      try {
        // First try to get from server
        const result = await getDocuments()
        
        // If no documents from server, try localStorage
        if (result.documents.length === 0) {
          const storedDocs = JSON.parse(localStorage.getItem('documents') || '[]')
          setDocuments(storedDocs)
        } else {
          setDocuments(result.documents)
          // Also update localStorage with server documents
          localStorage.setItem('documents', JSON.stringify(result.documents))
        }
      } catch (error) {
        console.error("Error fetching documents:", error)
        // Fallback to localStorage
        const storedDocs = JSON.parse(localStorage.getItem('documents') || '[]')
        setDocuments(storedDocs)
        
        toast({
          title: "Error",
          description: "Failed to load documents from server. Using locally stored data.",
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
        const updatedDocs = documents.filter((doc) => doc.id !== id)
        setDocuments(updatedDocs)
        
        // Also update localStorage
        localStorage.setItem('documents', JSON.stringify(updatedDocs))
        
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