/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Book, Note, View, MOCK_BOOKS, MOCK_NOTES } from './types';
import BooksView from './components/BooksView';
import SearchView from './components/SearchView';
import EditorView from './components/EditorView';

export default function App() {
  const [currentView, setCurrentView] = useState<View>('books');
  const [books, setBooks] = useState<Book[]>(MOCK_BOOKS);
  const [notes, setNotes] = useState<Note[]>(MOCK_NOTES);
  const [selectedNote, setSelectedNote] = useState<Note | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  const handleDeleteBook = (id: string) => {
    setBooks(books.filter(b => b.id !== id));
  };

  const handleCreateNote = () => {
    const newNote: Note = {
      id: `note-${Date.now()}`,
      bookId: '1', // Default to first book for now
      title: '',
      content: '',
      updatedAt: new Date().toLocaleString(),
    };
    setSelectedNote(newNote);
    setCurrentView('editor');
  };

  const handleOpenNote = (note: Note) => {
    setSelectedNote(note);
    setCurrentView('editor');
  };

  const handleBack = () => {
    if (currentView === 'editor') {
      setCurrentView('books');
    } else if (currentView === 'search') {
      setCurrentView('books');
    }
  };

  return (
    <div className="flex h-screen w-full flex-col overflow-hidden max-w-[430px] mx-auto bg-white dark:bg-slate-950 shadow-2xl relative">
      <AnimatePresence mode="wait">
        {currentView === 'books' && (
          <motion.div
            key="books"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="h-full w-full"
          >
            <BooksView 
              books={books} 
              onDelete={handleDeleteBook} 
              onCreateNote={handleCreateNote}
              onSearchClick={() => setCurrentView('search')}
              onBookClick={(book) => {
                // For demo, open the first note of this book or create a new one
                const bookNote = notes.find(n => n.bookId === book.id) || {
                  id: `new-${book.id}`,
                  bookId: book.id,
                  title: book.title,
                  content: '',
                  updatedAt: new Date().toLocaleString(),
                };
                handleOpenNote(bookNote);
              }}
            />
          </motion.div>
        )}

        {currentView === 'search' && (
          <motion.div
            key="search"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            className="h-full w-full"
          >
            <SearchView 
              query={searchQuery}
              onQueryChange={setSearchQuery}
              onBack={() => setCurrentView('books')}
              onNoteClick={handleOpenNote}
            />
          </motion.div>
        )}

        {currentView === 'editor' && selectedNote && (
          <motion.div
            key="editor"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
            className="h-full w-full"
          >
            <EditorView 
              note={selectedNote} 
              onBack={() => setCurrentView('books')}
              onSave={(updatedNote) => {
                setNotes(notes.map(n => n.id === updatedNote.id ? updatedNote : n));
                setCurrentView('books');
              }}
            />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
