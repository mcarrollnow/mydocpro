"use server"
import pdfParse from 'pdf-parse';
import mammoth from 'mammoth';
import Papa from 'papaparse';
import { marked } from 'marked';
import { revalidatePath } from "next/cache"

// Temporary module declarations for missing types
// @ts-ignore
declare module 'pdf-parse';
// @ts-ignore
declare module 'papaparse';

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
    const fileContent = await extractTextFromFile(file)

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
    // Return the document so the client can save it to localStorage
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
  return { success: true, deletedId: id }
}

// With this new function:
async function extractTextFromFile(file: File): Promise<string> {
  const fileType = file.name.split(".").pop()?.toLowerCase();
  
  try {
    switch (fileType) {
      case 'pdf':
        // Parse PDF files
        const arrayBuffer = await file.arrayBuffer();
        const buffer = Buffer.from(arrayBuffer);
        const pdfData = await pdfParse(buffer);
        return pdfData.text;
        
      case 'docx':
        // Parse Word documents
        const docxArrayBuffer = await file.arrayBuffer();
        const result = await mammoth.extractRawText({
          arrayBuffer: docxArrayBuffer
        });
        return result.value;
        
      case 'rtf':
        // For RTF files, you would need a specific RTF parser
        // This is a placeholder - you'd need to implement or find an RTF parser
        return `RTF parsing not implemented for ${file.name}. Consider converting to another format.`;
        
      case 'csv':
        // Parse CSV files
        const csvText = await file.text();
        const csvResult = Papa.parse(csvText, { header: true });
        // Convert CSV data to a readable string format
        return (csvResult.data as Record<string, string>[])
          .map((row: Record<string, string>) => Object.entries(row).map(([key, value]) => `${key}: ${value}`).join(', '))
          .join('\n');
        
      case 'md':
        // Parse Markdown files
        const mdText = await file.text();
        // Optional: convert markdown to plain text by removing markdown syntax
        const htmlContent = marked(mdText);
        // Strip HTML tags for plain text (simple approach)
        const plainText = (typeof htmlContent === 'string' ? htmlContent : '').replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();
        return plainText;
        
      case 'txt':
        // Text files can be read directly
        return await file.text();
        
      default:
        // For unknown file types, try to read as text
        try {
          return await file.text();
        } catch (error) {
          return `Unable to extract text from ${file.name}. Unsupported file format.`;
        }
    }
  } catch (error) {
    console.error(`Error parsing ${fileType} file:`, error);
    return `Failed to extract content from ${file.name}. Error: ${error}`;
  }
}
function formatFileSize(bytes: number): string {
  if (bytes < 1024) return bytes + " B"
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
  return (bytes / (1024 * 1024)).toFixed(1) + " MB"
}