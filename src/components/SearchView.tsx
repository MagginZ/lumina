import { ChevronLeft, X, Search, FileText, Sparkles, ChevronRight } from 'lucide-react';
import { Note, MOCK_NOTES } from '../types';
import { useState } from 'react';

interface SearchViewProps {
  query: string;
  onQueryChange: (query: string) => void;
  onBack: () => void;
  onNoteClick: (note: Note) => void;
}

export default function SearchView({ query, onQueryChange, onBack, onNoteClick }: SearchViewProps) {
  const [activeTab, setActiveTab] = useState('All');
  const tabs = ['All', 'Notes', 'Books', 'AI Chats'];

  // Filter notes based on query
  const filteredNotes = MOCK_NOTES.filter(note => 
    note.title.toLowerCase().includes(query.toLowerCase()) || 
    note.content.toLowerCase().includes(query.toLowerCase())
  );

  return (
    <div className="flex flex-col h-full bg-white dark:bg-slate-950">
      {/* Search Header */}
      <div className="sticky top-0 z-10 bg-white/80 dark:bg-slate-950/80 backdrop-blur-md">
        <div className="flex items-center p-4 pb-2 justify-between">
          <button onClick={onBack} className="text-primary flex items-center justify-center active:opacity-50 transition-opacity">
            <ChevronLeft size={28} />
          </button>
          <h2 className="text-slate-900 dark:text-slate-100 text-lg font-bold leading-tight tracking-tight flex-1 text-center pr-8">Search</h2>
          <button onClick={onBack} className="text-primary text-base font-medium active:opacity-50 transition-opacity">Cancel</button>
        </div>
        
        <div className="px-4 py-2">
          <div className="flex items-center rounded-xl h-11 bg-slate-100 dark:bg-slate-900 px-3">
            <Search className="text-slate-400 mr-2" size={20} />
            <input 
              autoFocus
              className="flex-1 bg-transparent border-none focus:ring-0 text-slate-900 dark:text-slate-100 placeholder:text-slate-400 p-0 text-base"
              value={query}
              onChange={(e) => onQueryChange(e.target.value)}
              placeholder="Search"
            />
            {query && (
              <button onClick={() => onQueryChange('')} className="text-slate-400 hover:text-slate-600 transition-colors">
                <X size={20} />
              </button>
            )}
          </div>
        </div>

        {/* Tabs */}
        <div className="px-4 pt-2 pb-1">
          <div className="flex border-b border-slate-200 dark:border-slate-800 gap-6">
            {tabs.map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`flex flex-col items-center justify-center border-b-2 pb-3 pt-2 transition-colors ${
                  activeTab === tab ? 'border-primary text-slate-900 dark:text-slate-100' : 'border-transparent text-slate-400'
                }`}
              >
                <p className={`text-sm ${activeTab === tab ? 'font-semibold' : 'font-medium'}`}>{tab}</p>
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Results */}
      <div className="flex-1 overflow-y-auto no-scrollbar">
        {query && (
          <>
            <div className="mt-4">
              <div className="px-4 py-2">
                <h3 className="text-slate-400 text-xs font-bold uppercase tracking-wider">
                  The Great <span className="text-primary">{query}</span>
                </h3>
              </div>
              
              <div className="space-y-0.5">
                {filteredNotes.map((note) => (
                  <div 
                    key={note.id}
                    onClick={() => onNoteClick(note)}
                    className="flex items-center gap-4 bg-white dark:bg-slate-950 px-4 py-3 active:bg-slate-50 dark:active:bg-slate-900 cursor-pointer transition-colors border-b border-slate-100 dark:border-slate-900"
                  >
                    <div className={`flex items-center justify-center rounded-lg shrink-0 size-11 ${
                      note.isAiGenerated ? 'bg-amber-100 text-amber-600' : 'bg-primary/10 text-primary'
                    }`}>
                      {note.isAiGenerated ? <Sparkles size={24} /> : <FileText size={24} />}
                    </div>
                    <div className="flex flex-col flex-1 justify-center min-w-0">
                      <p className="text-slate-900 dark:text-slate-100 text-[15px] font-semibold leading-tight truncate">
                        {note.title}
                      </p>
                      <p className="text-slate-500 dark:text-slate-400 text-sm font-normal leading-snug line-clamp-2 mt-0.5">
                        {note.content}
                      </p>
                    </div>
                    <div className="shrink-0 text-slate-300 dark:text-slate-700">
                      <ChevronRight size={20} />
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* AI Insights Card */}
            <div className="mt-6 px-4">
              <div className="bg-primary/5 dark:bg-primary/10 rounded-xl p-4 border border-primary/20">
                <div className="flex items-center gap-2 mb-3">
                  <Sparkles className="text-primary" size={20} />
                  <h3 className="text-primary text-sm font-bold uppercase tracking-tight">AI Insights</h3>
                </div>
                <p className="text-slate-600 dark:text-slate-400 text-sm leading-relaxed">
                  You have {filteredNotes.length} notes referencing <span className="font-bold text-slate-900 dark:text-slate-100">"{query}"</span> across 3 different books. Would you like a combined summary of his character development?
                </p>
                <button className="mt-4 w-full bg-primary text-white py-2 rounded-lg font-semibold text-sm shadow-md shadow-primary/20 active:scale-[0.98] transition-transform">
                  Generate Synthesis
                </button>
              </div>
            </div>
          </>
        )}
        
        {!query && (
          <div className="flex flex-col items-center justify-center h-64 text-slate-400">
            <Search size={48} className="opacity-20 mb-4" />
            <p className="text-sm">Search for notes, books, or AI chats</p>
          </div>
        )}
        
        <div className="h-20"></div>
      </div>
    </div>
  );
}
