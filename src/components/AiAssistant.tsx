import { motion, AnimatePresence } from 'motion/react';
import { Sparkles, X, ArrowUpCircle, Plus } from 'lucide-react';
import { useState } from 'react';

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

interface AiAssistantProps {
  isOpen: boolean;
  onClose: () => void;
  noteContent: string;
}

export default function AiAssistant({ isOpen, onClose, noteContent }: AiAssistantProps) {
  const [messages, setMessages] = useState<Message[]>([
    {
      role: 'user',
      content: 'Can you summarize the main point about AI interaction models in this note?'
    },
    {
      role: 'assistant',
      content: 'The main point is that AI should function as a **subtle assistant** within direct manipulation interfaces, rather than taking the lead. This approach focuses on reducing friction to make digital expression feel as natural and instantaneous as thought itself.'
    }
  ]);
  const [input, setInput] = useState('');

  const handleSend = () => {
    if (!input.trim()) return;
    setMessages([...messages, { role: 'user', content: input }]);
    setInput('');
    // Simulate AI response
    setTimeout(() => {
      setMessages(prev => [...prev, { 
        role: 'assistant', 
        content: 'I am analyzing your request based on the note content...' 
      }]);
    }, 1000);
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/20 backdrop-blur-[2px] z-40"
          />
          
          {/* Bottom Sheet */}
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
            className="fixed bottom-0 left-0 right-0 max-w-[430px] mx-auto bg-white dark:bg-slate-900 rounded-t-[24px] shadow-2xl z-50 flex flex-col max-h-[80vh]"
          >
            {/* Handle */}
            <div className="w-full flex justify-center pt-3 pb-1">
              <div className="w-10 h-1 bg-slate-200 dark:bg-slate-700 rounded-full" />
            </div>

            {/* Header */}
            <div className="flex items-center justify-between px-5 py-3 border-b border-slate-100 dark:border-slate-800">
              <div className="flex items-center gap-2">
                <Sparkles className="text-primary" size={20} />
                <h2 className="text-[17px] font-bold text-slate-900 dark:text-white">AI Assistant</h2>
              </div>
              <button 
                onClick={onClose}
                className="size-8 flex items-center justify-center bg-slate-100 dark:bg-slate-800 rounded-full text-slate-500 dark:text-slate-400"
              >
                <X size={18} />
              </button>
            </div>

            {/* Chat Messages */}
            <div className="flex-1 overflow-y-auto p-5 space-y-4 no-scrollbar">
              {messages.map((msg, i) => (
                <div 
                  key={i} 
                  className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
                >
                  <div className={`max-w-[85%] rounded-2xl px-4 py-3 text-[15px] leading-relaxed ${
                    msg.role === 'user' 
                      ? 'bg-primary text-white rounded-tr-none' 
                      : 'bg-slate-100 dark:bg-slate-800 text-slate-800 dark:text-slate-200 rounded-tl-none'
                  }`}>
                    {msg.content}
                    {msg.role === 'assistant' && (
                      <button className="mt-3 flex items-center gap-1.5 text-primary text-xs font-bold uppercase tracking-tight hover:opacity-70 transition-opacity">
                        <Plus size={14} />
                        <span>Save to this Note</span>
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>

            {/* Input Area */}
            <div className="p-4 border-t border-slate-100 dark:border-slate-800">
              <div className="relative flex items-center">
                <input
                  type="text"
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                  placeholder="Ask about this note..."
                  className="w-full bg-slate-100 dark:bg-slate-800 border-none rounded-full py-3 pl-5 pr-12 text-[15px] text-slate-900 dark:text-white placeholder:text-slate-400 focus:ring-2 focus:ring-primary/20"
                />
                <button 
                  onClick={handleSend}
                  className="absolute right-2 text-primary active:scale-90 transition-transform"
                >
                  <ArrowUpCircle size={32} />
                </button>
              </div>
              {/* iOS Home Indicator Space */}
              <div className="h-6" />
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
