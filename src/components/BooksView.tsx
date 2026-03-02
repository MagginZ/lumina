import { Search, Mic, Plus, Trash2, Edit3 } from 'lucide-react';
import { Book } from '../types';
import { motion, AnimatePresence } from 'motion/react';
import { useState } from 'react';

interface BooksViewProps {
  books: Book[];
  onDelete: (id: string) => void;
  onCreateNote: () => void;
  onSearchClick: () => void;
  onBookClick: (book: Book) => void;
}

export default function BooksView({ books, onDelete, onCreateNote, onSearchClick, onBookClick }: BooksViewProps) {
  const [swipedId, setSwipedId] = useState<string | null>(null);
  const [confirmDeleteId, setConfirmDeleteId] = useState<string | null>(null);

  const handleDelete = (id: string) => {
    onDelete(id);
    setConfirmDeleteId(null);
    setSwipedId(null);
  };

  return (
    <div className="flex flex-col h-full bg-white dark:bg-slate-950">
      {/* Header */}
      <div className="sticky top-0 z-20 bg-white/95 dark:bg-slate-950/95 backdrop-blur-md px-4 pt-10 pb-4">
        <div className="flex items-center justify-between mb-2">
          <h1 className="text-4xl font-bold tracking-tight text-slate-900 dark:text-white">Books</h1>
          <button 
            onClick={onCreateNote}
            className="text-primary p-1 active:opacity-50 transition-opacity"
          >
            <Plus size={28} strokeWidth={2.5} />
          </button>
        </div>
        
        {/* Search Bar */}
        <div className="mt-4" onClick={onSearchClick}>
          <div className="flex items-center rounded-xl h-10 bg-slate-100 dark:bg-slate-900 px-3 cursor-text">
            <Search className="text-slate-400 mr-2" size={20} />
            <span className="text-slate-400 text-[17px] flex-1">Search</span>
            <Mic className="text-slate-400 ml-2" size={20} />
          </div>
        </div>
      </div>

      {/* Book List */}
      <div className="flex-1 overflow-y-auto pb-10 px-4 no-scrollbar">
        <div className="space-y-0.5">
          {books.map((book) => (
            <div key={book.id} className="relative overflow-hidden group">
              {/* Swipe Action Background */}
              <div className="absolute inset-0 bg-ios-red flex items-center justify-end px-6">
                <button 
                  onClick={() => setConfirmDeleteId(book.id)}
                  className="text-white flex flex-col items-center gap-1"
                >
                  <Trash2 size={24} />
                  <span className="text-[11px] font-semibold uppercase">Delete</span>
                </button>
              </div>

              {/* Book Item Content */}
              <motion.div
                drag="x"
                dragConstraints={{ left: -80, right: 0 }}
                dragElastic={0.1}
                onDragEnd={(_, info) => {
                  if (info.offset.x < -40) {
                    setSwipedId(book.id);
                  } else {
                    setSwipedId(null);
                  }
                }}
                animate={{ x: swipedId === book.id ? -80 : 0 }}
                onClick={() => onBookClick(book)}
                className="bg-white dark:bg-slate-950 flex flex-col py-3 border-b border-slate-100 dark:border-slate-800 cursor-pointer active:bg-slate-50 dark:active:bg-slate-900 transition-colors relative z-10"
              >
                <div className="flex justify-between items-baseline gap-2">
                  <p className="text-slate-900 dark:text-slate-100 text-[17px] font-bold leading-tight truncate">
                    {book.title}
                  </p>
                  <span className="text-slate-400 dark:text-slate-500 text-sm whitespace-nowrap">
                    {book.updatedAt}
                  </span>
                </div>
                <div className="flex items-center gap-1.5 mt-0.5">
                  <p className="text-slate-500 dark:text-slate-400 text-[15px] font-normal truncate">
                    {book.author}
                  </p>
                </div>
                {book.lastNotePreview && (
                  <p className="text-slate-400 dark:text-slate-500 text-[14px] font-normal line-clamp-1 mt-0.5 italic">
                    {book.lastNotePreview}
                  </p>
                )}
              </motion.div>
            </div>
          ))}
        </div>
        
        <div className="py-12 text-center">
          <p className="text-slate-400 text-sm">{books.length} Books</p>
        </div>
      </div>

      {/* Floating Action Button */}
      <div className="fixed bottom-8 right-8 z-30">
        <button 
          onClick={onCreateNote}
          className="bg-primary text-white size-14 rounded-full shadow-lg flex items-center justify-center active:scale-95 transition-transform"
        >
          <Edit3 size={28} />
        </button>
      </div>

      {/* Delete Confirmation Dialog */}
      <AnimatePresence>
        {confirmDeleteId && (
          <div className="fixed inset-0 z-50 flex items-center justify-center px-12">
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 bg-black/40 ios-alert-blur"
              onClick={() => setConfirmDeleteId(null)}
            />
            <motion.div 
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.9 }}
              className="relative w-full max-w-[270px] bg-[#f2f2f2]/95 dark:bg-[#1e1e1e]/95 backdrop-blur-2xl rounded-[14px] flex flex-col overflow-hidden shadow-2xl"
            >
              <div className="p-4 flex flex-col items-center text-center">
                <h2 className="text-[17px] font-semibold text-black dark:text-white leading-tight">Delete Book?</h2>
                <p className="mt-1 text-[13px] font-normal text-black dark:text-white leading-snug">
                  Are you sure you want to delete "{books.find(b => b.id === confirmDeleteId)?.title}" and all its notes? This action cannot be undone.
                </p>
              </div>
              <div className="flex border-t border-black/10 dark:border-white/10">
                <button 
                  onClick={() => setConfirmDeleteId(null)}
                  className="flex-1 h-11 text-[17px] font-normal text-primary border-r border-black/10 dark:border-white/10 active:bg-black/5 dark:active:bg-white/5 transition-colors"
                >
                  Cancel
                </button>
                <button 
                  onClick={() => handleDelete(confirmDeleteId)}
                  className="flex-1 h-11 text-[17px] font-semibold text-ios-red active:bg-black/5 dark:active:bg-white/5 transition-colors"
                >
                  Delete
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
