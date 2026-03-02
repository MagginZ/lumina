import { ChevronLeft, Share, Maximize2, Sparkles, RefreshCw, CheckCircle, Camera, PenTool, Edit3, MoreHorizontal } from 'lucide-react';
import { Note } from '../types';
import { useState } from 'react';
import AiAssistant from './AiAssistant';

interface EditorViewProps {
  note: Note;
  onBack: () => void;
  onSave: (note: Note) => void;
}

export default function EditorView({ note, onBack, onSave }: EditorViewProps) {
  const [title, setTitle] = useState(note.title);
  const [content, setContent] = useState(note.content);
  const [isAiOpen, setIsAiOpen] = useState(false);

  const handleDone = () => {
    onSave({ ...note, title, content });
  };

  return (
    <div className="flex flex-col h-full bg-background-light dark:bg-background-dark">
      {/* Top Navigation Bar */}
      <header className="flex items-center justify-between px-4 py-3 bg-background-light/80 dark:bg-background-dark/80 backdrop-blur-md sticky top-0 z-10">
        <button onClick={onBack} className="text-primary flex items-center gap-1 transition-opacity active:opacity-50">
          <ChevronLeft size={28} />
          <span className="text-lg">Notes</span>
        </button>
        <div className="flex gap-4 items-center">
          <button 
            onClick={() => setIsAiOpen(true)}
            className="text-primary active:opacity-50 transition-opacity"
          >
            <Sparkles size={22} />
          </button>
          <button className="text-primary active:opacity-50 transition-opacity">
            <Share size={24} />
          </button>
          <button className="text-primary active:opacity-50 transition-opacity">
            <MoreHorizontal size={24} />
          </button>
          <button onClick={handleDone} className="text-primary text-lg font-semibold tracking-tight active:opacity-50 transition-opacity">
            Done
          </button>
        </div>
      </header>

      {/* Main Content Scroll Area */}
      <main className="flex-1 overflow-y-auto no-scrollbar">
        <div className="max-w-screen-md mx-auto">
          {/* Title Section */}
          <div className="px-5 pt-6 pb-2">
            <input 
              className="w-full bg-transparent border-none p-0 text-3xl font-bold text-slate-900 dark:text-slate-100 placeholder:text-slate-300 dark:placeholder:text-slate-700 focus:ring-0 focus:outline-none" 
              placeholder="Note Title" 
              type="text" 
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
          </div>

          {/* AI Image Section */}
          {note.imageUrl && (
            <div className="px-5 py-4">
              <div className="group relative flex flex-col rounded-xl overflow-hidden bg-slate-200 dark:bg-slate-800 ring-1 ring-slate-200 dark:ring-slate-800">
                <div 
                  className="aspect-[4/3] w-full bg-center bg-cover cursor-pointer hover:opacity-95 transition-opacity" 
                  style={{ backgroundImage: `url("${note.imageUrl}")` }}
                >
                </div>
                <div className="absolute top-3 right-3 flex gap-2">
                  <button className="flex items-center justify-center bg-black/40 backdrop-blur-md text-white rounded-full p-2 hover:bg-black/60 transition-colors">
                    <Maximize2 size={20} />
                  </button>
                </div>
                <div className="flex items-center justify-between p-3 bg-white/10 dark:bg-black/10 backdrop-blur-xl border-t border-white/20 dark:border-white/5">
                  <div className="flex items-center gap-2">
                    <Sparkles className="text-primary" size={18} />
                    <span className="text-xs font-medium text-slate-500 dark:text-slate-400">AI Generated</span>
                  </div>
                  <button className="flex items-center gap-1 px-3 py-1.5 bg-primary/10 dark:bg-primary/20 text-primary rounded-full text-sm font-semibold hover:bg-primary/20 transition-colors">
                    <RefreshCw size={14} />
                    <span>Replace</span>
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Remarks/Body Section */}
          <div className="px-5 py-2">
            <textarea 
              className="w-full min-h-[300px] bg-transparent border-none p-0 text-lg leading-relaxed text-slate-800 dark:text-slate-200 placeholder:text-slate-400 dark:placeholder:text-slate-600 focus:ring-0 focus:outline-none resize-none" 
              placeholder="Start typing your notes here..."
              value={content}
              onChange={(e) => setContent(e.target.value)}
            />
          </div>

          {/* Footer Timestamp */}
          <footer className="mt-8 pb-12 px-5">
            <p className="text-slate-400 dark:text-slate-600 text-sm font-medium text-center uppercase tracking-wider">
              Edited {note.updatedAt}
            </p>
          </footer>
        </div>
      </main>

      {/* Bottom Toolbar (iOS style) */}
      <div className="px-6 py-4 border-t border-slate-200 dark:border-slate-800 flex justify-between items-center bg-background-light/80 dark:bg-background-dark/80 backdrop-blur-md">
        <button className="text-primary transition-opacity active:opacity-50">
          <CheckCircle size={24} />
        </button>
        <button className="text-primary transition-opacity active:opacity-50">
          <Camera size={24} />
        </button>
        <button className="text-primary transition-opacity active:opacity-50">
          <PenTool size={24} />
        </button>
        <button className="text-primary transition-opacity active:opacity-50">
          <Edit3 size={24} />
        </button>
      </div>

      {/* AI Assistant Modal */}
      <AiAssistant 
        isOpen={isAiOpen} 
        onClose={() => setIsAiOpen(false)} 
        noteContent={content}
      />
    </div>
  );
}
