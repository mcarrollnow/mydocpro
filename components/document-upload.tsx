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

        if (result.success && result.document) {
          setUploadProgress((prev) => ({
            ...prev,
            [file.name]: 100,
          }))

          // Save document to localStorage
          const storedDocs = JSON.parse(localStorage.getItem('documents') || '[]')
          storedDocs.push(result.document)
          localStorage.setItem('documents', JSON.stringify(storedDocs))

          toast({
            title: "Document uploaded",
            description: `${file.name} has been processed successfully.`,
          })
        } else {
          throw new Error(result.error || "Upload failed")
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