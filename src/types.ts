export interface Note {
  id: string;
  title: string;
  content: string;
  imageUrl?: string;
  isAiGenerated?: boolean;
  updatedAt: string;
  bookId: string;
}

export interface Book {
  id: string;
  title: string;
  author: string;
  lastNotePreview?: string;
  updatedAt: string;
}

export type View = 'books' | 'search' | 'editor';

export const MOCK_BOOKS: Book[] = [];

export const MOCK_NOTES: Note[] = [];
