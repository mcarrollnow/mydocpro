// lib/document-store.ts

export type Document = {
  id: string
  name: string
  type: string
  size: string
  uploadedAt: string
  content: string
  embedding?: number[]
}

// Save a document to localStorage
export function saveDocument(document: Document): void {
  if (typeof window === 'undefined') return;
  
  const documents = getDocuments();
  const existingIndex = documents.findIndex(doc => doc.id === document.id);
  
  if (existingIndex >= 0) {
    // Update existing document
    documents[existingIndex] = document;
  } else {
    // Add new document
    documents.push(document);
  }
  
  localStorage.setItem('documents', JSON.stringify(documents));
}

// Save multiple documents to localStorage
export function saveDocuments(documents: Document[]): void {
  if (typeof window === 'undefined') return;
  localStorage.setItem('documents', JSON.stringify(documents));
}

// Get all documents from localStorage
export function getDocuments(): Document[] {
  if (typeof window === 'undefined') return [];
  
  const storedDocs = localStorage.getItem('documents');
  return storedDocs ? JSON.parse(storedDocs) : [];
}

// Get a document by ID from localStorage
export function getDocumentById(id: string): Document | undefined {
  if (typeof window === 'undefined') return undefined;
  
  const documents = getDocuments();
  return documents.find(doc => doc.id === id);
}

// Delete a document from localStorage
export function deleteDocument(id: string): void {
  if (typeof window === 'undefined') return;
  
  const documents = getDocuments();
  const filteredDocs = documents.filter(doc => doc.id !== id);
  localStorage.setItem('documents', JSON.stringify(filteredDocs));
}

// Clear all documents from localStorage
export function clearDocuments(): void {
  if (typeof window === 'undefined') return;
  localStorage.removeItem('documents');
}