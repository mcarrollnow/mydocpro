"use server"
import { PDFDocument } from 'pdf-lib';
import mammoth from 'mammoth';
import Papa from 'papaparse';
import { marked } from 'marked';
import { revalidatePath } from "next/cache"
import { put, del } from '@vercel/blob'

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
  fileUrl: string
}[] = []

// In-memory temporary store for parsed content
const parsedContentStore: { [docId: string]: string } = {};

export async function uploadDocument(formData: FormData) {
  try {
    const file = formData.get("file") as File;
    if (!file) {
      return { success: false, error: "No file provided" };
    }
    // Upload the file to Vercel Blob Storage
    const blob = await put(`documents/${Date.now()}-${file.name}`, file, {
      access: 'public',
    });
    const fileUrl = blob.url;
    const docId = Date.now().toString();
    // Only return fileUrl and docId, do not parse yet
    return { success: true, fileUrl, docId, name: file.name, size: file.size, type: file.name.split('.').pop() || 'unknown' };
  } catch (error) {
    console.error("Error uploading document:", error);
    return { success: false, error: "Failed to upload document" };
  }
}

export async function parseDocument(docId: string, fileUrl: string, type: string) {
  try {
    // Download the file from Blob Storage
    let fileFetchUrl = fileUrl;
    if (fileUrl && fileUrl.startsWith("/")) {
      // If fileUrl is a relative path, make it absolute
      const baseUrl = process.env.VERCEL_URL
        ? `https://${process.env.VERCEL_URL}`
        : "http://localhost:3000";
      fileFetchUrl = `${baseUrl}${fileUrl}`;
    }
    const response = await fetch(fileFetchUrl);
    if (!response.ok) throw new Error('Failed to fetch file from Blob Storage');
    const arrayBuffer = await response.arrayBuffer();
    let content = '';
    switch (type) {
      case 'pdf':
        // pdf-lib does not support text extraction directly
        content = 'PDF text extraction is not supported with pdf-lib. Please use a different library for extracting text from PDFs.';
        break;
      case 'docx':
        const result = await mammoth.extractRawText({ arrayBuffer });
        content = result.value;
        break;
      case 'rtf':
        content = 'RTF parsing not implemented.';
        break;
      case 'csv':
        const csvText = new TextDecoder().decode(arrayBuffer);
        const csvResult = Papa.parse(csvText, { header: true });
        content = (csvResult.data as Record<string, string>[])
          .map((row: Record<string, string>) => Object.entries(row).map(([key, value]) => `${key}: ${value}`).join(', '))
          .join('\n');
        break;
      case 'md':
        const mdText = new TextDecoder().decode(arrayBuffer);
        const htmlContent = marked(mdText);
        content = (typeof htmlContent === 'string' ? htmlContent : '').replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();
        break;
      case 'txt':
        content = new TextDecoder().decode(arrayBuffer);
        break;
      default:
        content = new TextDecoder().decode(arrayBuffer);
    }
    parsedContentStore[docId] = content;
    return { success: true, content };
  } catch (error) {
    console.error('Error parsing document:', error);
    return { success: false, error: 'Failed to parse document' };
  }
}

export async function deleteDocument(docId: string, fileUrl: string) {
  try {
    // Delete from Blob Storage
    const url = new URL(fileUrl);
    const key = url.pathname.replace(/^\//, '');
    await del(key);
    // Remove parsed content
    delete parsedContentStore[docId];
    return { success: true };
  } catch (error) {
    console.error('Error deleting document:', error);
    return { success: false, error: 'Failed to delete document' };
  }
}

export async function getParsedContent(docId: string) {
  return parsedContentStore[docId] || null;
}

export async function getDocuments() {
  return { documents }
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
        const pdfDoc = await PDFDocument.load(buffer);
        // pdf-lib does not support text extraction directly
        // You would need a different library for actual text extraction
        return 'PDF text extraction is not supported with pdf-lib. Please use a different library for extracting text from PDFs.';
        
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