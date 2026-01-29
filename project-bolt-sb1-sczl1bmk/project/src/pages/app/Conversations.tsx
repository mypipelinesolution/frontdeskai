import { useState, useEffect, useRef } from 'react';
import { supabase, Lead, Message, Workspace } from '../../lib/supabase';
import { Send, Search, Mail, Phone } from 'lucide-react';

export function Conversations({ workspace }: { workspace: Workspace }) {
  const [leads, setLeads] = useState<Lead[]>([]);
  const [selectedLead, setSelectedLead] = useState<Lead | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [sending, setSending] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    loadLeads();
  }, [workspace.id]);

  useEffect(() => {
    if (selectedLead) {
      loadMessages(selectedLead.id);
      const subscription = supabase
        .channel(`messages:${selectedLead.id}`)
        .on(
          'postgres_changes',
          {
            event: '*',
            schema: 'public',
            table: 'messages',
            filter: `lead_id=eq.${selectedLead.id}`,
          },
          () => {
            loadMessages(selectedLead.id);
          }
        )
        .subscribe();

      return () => {
        subscription.unsubscribe();
      };
    }
  }, [selectedLead]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const loadLeads = async () => {
    const { data } = await supabase
      .from('leads')
      .select('*')
      .eq('workspace_id', workspace.id)
      .order('last_contact_at', { ascending: false, nullsFirst: false })
      .order('created_at', { ascending: false });

    if (data) setLeads(data);
  };

  const loadMessages = async (leadId: string) => {
    const { data } = await supabase
      .from('messages')
      .select('*')
      .eq('lead_id', leadId)
      .order('created_at', { ascending: true });

    if (data) setMessages(data);
  };

  const sendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newMessage.trim() || !selectedLead || sending) return;

    setSending(true);

    try {
      const channel = selectedLead.email ? 'email' : 'sms';
      const endpoint = channel === 'email' ? 'send-email' : 'send-sms';

      const payload = channel === 'email' ? {
        workspaceId: workspace.id,
        leadId: selectedLead.id,
        to: selectedLead.email,
        subject: `Message from ${workspace.business_name}`,
        message: newMessage,
      } : {
        workspaceId: workspace.id,
        leadId: selectedLead.id,
        to: selectedLead.phone,
        message: newMessage,
      };

      const response = await fetch(
        `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/${endpoint}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
          },
          body: JSON.stringify(payload),
        }
      );

      const result = await response.json();

      if (result.success) {
        setNewMessage('');
        await loadMessages(selectedLead.id);
      } else {
        alert('Failed to send message: ' + result.error);
      }
    } catch (error) {
      console.error('Send error:', error);
      alert('Failed to send message');
    } finally {
      setSending(false);
    }
  };

  const filteredLeads = leads.filter(lead =>
    lead.full_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    lead.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    lead.phone?.includes(searchTerm)
  );

  return (
    <div className="h-[calc(100vh-8rem)] flex flex-col">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-slate-900">Conversations</h1>
        <p className="text-slate-600 mt-1">Message your leads via SMS and email</p>
      </div>

      <div className="flex-1 bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden flex">
        <div className="w-80 border-r border-slate-200 flex flex-col">
          <div className="p-4 border-b border-slate-200">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
              <input
                type="text"
                placeholder="Search leads..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-9 pr-4 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none"
              />
            </div>
          </div>

          <div className="flex-1 overflow-y-auto">
            {filteredLeads.length === 0 ? (
              <div className="p-4 text-center text-slate-500 text-sm">
                No leads found
              </div>
            ) : (
              filteredLeads.map((lead) => (
                <button
                  key={lead.id}
                  onClick={() => setSelectedLead(lead)}
                  className={`w-full p-4 border-b border-slate-200 text-left hover:bg-slate-50 transition ${
                    selectedLead?.id === lead.id ? 'bg-blue-50' : ''
                  }`}
                >
                  <h3 className="font-semibold text-slate-900 mb-1">{lead.full_name}</h3>
                  <div className="text-xs text-slate-600 space-y-0.5">
                    {lead.email && (
                      <div className="flex items-center gap-1">
                        <Mail className="w-3 h-3" />
                        <span className="truncate">{lead.email}</span>
                      </div>
                    )}
                    {lead.phone && (
                      <div className="flex items-center gap-1">
                        <Phone className="w-3 h-3" />
                        <span>{lead.phone}</span>
                      </div>
                    )}
                  </div>
                  <span className={`inline-block mt-2 px-2 py-0.5 rounded text-xs ${
                    lead.status === 'new' ? 'bg-green-100 text-green-700' :
                    lead.status === 'contacted' ? 'bg-blue-100 text-blue-700' :
                    'bg-slate-100 text-slate-700'
                  }`}>
                    {lead.status}
                  </span>
                </button>
              ))
            )}
          </div>
        </div>

        <div className="flex-1 flex flex-col">
          {selectedLead ? (
            <>
              <div className="p-4 border-b border-slate-200">
                <h2 className="font-bold text-slate-900">{selectedLead.full_name}</h2>
                <div className="flex items-center gap-4 mt-1 text-sm text-slate-600">
                  {selectedLead.email && (
                    <div className="flex items-center gap-1">
                      <Mail className="w-4 h-4" />
                      {selectedLead.email}
                    </div>
                  )}
                  {selectedLead.phone && (
                    <div className="flex items-center gap-1">
                      <Phone className="w-4 h-4" />
                      {selectedLead.phone}
                    </div>
                  )}
                </div>
              </div>

              <div className="flex-1 overflow-y-auto p-4 space-y-3">
                {messages.length === 0 ? (
                  <div className="text-center text-slate-500 py-8">
                    No messages yet. Start a conversation!
                  </div>
                ) : (
                  messages.map((message) => (
                    <div
                      key={message.id}
                      className={`flex ${message.direction === 'outbound' ? 'justify-end' : 'justify-start'}`}
                    >
                      <div
                        className={`max-w-[70%] rounded-lg px-4 py-2 ${
                          message.direction === 'outbound'
                            ? 'bg-blue-600 text-white'
                            : 'bg-slate-100 text-slate-900'
                        }`}
                      >
                        <p className="text-sm whitespace-pre-wrap">{message.body}</p>
                        <div className={`text-xs mt-1 ${
                          message.direction === 'outbound' ? 'text-blue-100' : 'text-slate-500'
                        }`}>
                          {new Date(message.created_at).toLocaleString()} · {message.channel}
                        </div>
                      </div>
                    </div>
                  ))
                )}
                <div ref={messagesEndRef} />
              </div>

              <form onSubmit={sendMessage} className="p-4 border-t border-slate-200">
                <div className="flex gap-2">
                  <input
                    type="text"
                    value={newMessage}
                    onChange={(e) => setNewMessage(e.target.value)}
                    placeholder={`Send via ${selectedLead.email ? 'email' : 'SMS'}...`}
                    className="flex-1 px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    disabled={sending}
                  />
                  <button
                    type="submit"
                    disabled={sending || !newMessage.trim()}
                    className="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition disabled:opacity-50 flex items-center gap-2"
                  >
                    <Send className="w-4 h-4" />
                    {sending ? 'Sending...' : 'Send'}
                  </button>
                </div>
              </form>
            </>
          ) : (
            <div className="flex-1 flex items-center justify-center text-slate-500">
              <div className="text-center">
                <Mail className="w-16 h-16 mx-auto mb-4 text-slate-300" />
                <p>Select a lead to view conversation</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
