import 'package:flutter/material.dart';

import '../models/complaint.dart';





class AssistanceScreen extends StatefulWidget {
  const AssistanceScreen({Key? key}) : super(key: key);

  @override
  _AssistanceScreenState createState() => _AssistanceScreenState();
}

class _AssistanceScreenState extends State<AssistanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<SupportMessage> _messages = []; // Remplacer par vos données
  final List<Complaint> _complaints = []; // Remplacer par vos données
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistance'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.message), text: 'Messages'),
            Tab(icon: Icon(Icons.report_problem), text: 'Réclamations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Messages
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),

          // Onglet Réclamations
          _buildComplaintsTab(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportMessage message) {
    return Align(
      alignment: message.isFromCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isFromCurrentUser
              ? Colors.blue.shade100
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(message.content),
            const SizedBox(height: 4),
            Text(
              '${message.sentAt.hour}:${message.sentAt.minute}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Tapez votre message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Bouton pour créer une nouvelle réclamation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => _showCreateComplaintDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle Réclamation'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),

          // Liste des réclamations
          if (_complaints.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Aucune réclamation pour le moment'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                final complaint = _complaints[index];
                return _buildComplaintCard(complaint);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(complaint.title),
        subtitle: Text(
          complaint.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          complaint.isResolved ? Icons.check_circle : Icons.pending_actions,
          color: complaint.isResolved ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final newMessage = SupportMessage(
        id: DateTime.now().toString(),
        senderId: 'current_user_id',
        senderName: 'Moi',
        content: message,
        sentAt: DateTime.now(),
        isFromCurrentUser: true,
      );

      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
      });

      // TODO: Envoyer le message au backend
    }
  }

  void _showCreateComplaintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle Réclamation'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Sujet',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un sujet';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    if (value.length < 10) {
                      return 'La description doit contenir au moins 10 caractères';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final newComplaint = Complaint(
                  id: DateTime.now().toString(),
                  userId: 'current_user_id',
                  title: _titleController.text,
                  description: _descriptionController.text,
                  createdAt: DateTime.now(),
                );

                setState(() {
                  _complaints.add(newComplaint);
                  _titleController.clear();
                  _descriptionController.clear();
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Votre réclamation a été enregistrée'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}