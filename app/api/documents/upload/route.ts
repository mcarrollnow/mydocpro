import { put } from '@vercel/blob';
import { NextResponse } from 'next/server';

async function streamToBuffer(stream: ReadableStream<Uint8Array> | null): Promise<Buffer> {
  if (!stream) return Buffer.alloc(0);
  const reader = stream.getReader();
  const chunks = [];
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    if (value) chunks.push(value);
  }
  return Buffer.concat(chunks.map((chunk) => Buffer.from(chunk)));
}

export async function POST(request: Request): Promise<NextResponse> {
  const { searchParams } = new URL(request.url);
  const filename = searchParams.get('filename');
  if (!filename) {
    return NextResponse.json({ error: 'Missing filename' }, { status: 400 });
  }
  const buffer = await streamToBuffer(request.body);
  if (!buffer.length) {
    return NextResponse.json({ error: 'No file data received' }, { status: 400 });
  }
  const blob = await put(filename, buffer, {
    access: 'public',
  });
  return NextResponse.json(blob);
} 