import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bottomappbar.dart';
import 'messages_page.dart';

class Contact {
  final String name;
  final String role;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isOnline;

  Contact({
    required this.name,
    required this.role,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isOnline = false,
  });
}

class ContactsListScreen extends StatelessWidget {
  final List<Contact> contacts = [
    // Admin contacts
    Contact(
      name: "Dr. Sarah Johnson",
      role: "Admin",
      lastMessage: "Patient reports reviewed",
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
      isOnline: true,
    ),
    Contact(
      name: "Dr. Michael Chen",
      role: "Admin",
      lastMessage: "Updates on department meeting",
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),

    // Nurse contacts
    Contact(
      name: "Emma Thompson",
      role: "Nurse",
      lastMessage: "Medication schedule updated",
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 45)),
      isOnline: true,
    ),
    Contact(
      name: "James Wilson",
      role: "Nurse",
      lastMessage: "Patient vitals recorded",
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      isOnline: true,
    ),

    // Nutritionist contacts
    Contact(
      name: "Lisa Martinez",
      role: "Nutritionist",
      lastMessage: "New diet plan ready",
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      isOnline: true,
    ),
    Contact(
      name: "David Brown",
      role: "Nutritionist",
      lastMessage: "Dietary recommendations sent",
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 4)),
    ),

    // Relative contacts
    Contact(
      name: "Mary Smith",
      role: "Relative",
      lastMessage: "Thanks for the update",
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Contact(
      name: "John Davis",
      role: "Relative",
      lastMessage: "Will visit tomorrow",
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 6)),
      isOnline: true,
    ),
  ];

  Map<String, List<Contact>> _groupContactsByRole() {
    // Create a map to store contacts by role
    final grouped = <String, List<Contact>>{};

    // Group contacts by their roles
    for (var contact in contacts) {
      if (!grouped.containsKey(contact.role)) {
        grouped[contact.role] = [];
      }
      grouped[contact.role]!.add(contact);
    }

    // Define the desired order of roles
    final roleOrder = ["Admin", "Nurse", "Nutritionist", "Relative"];

    // Create a new map with the sorted roles
    final sortedGroups = Map.fromEntries(
        roleOrder.map((role) => MapEntry(role, grouped[role] ?? [])));

    return sortedGroups;
  }

  ContactsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupedContacts = _groupContactsByRole();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 70,
            floating: false,
            pinned: true,
            elevation: 0,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Messages',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.cyan[500] ?? Colors.cyan,
                      Colors.blue[600] ?? Colors.blue,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.search,
                  size: 28,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(right: 16, top: 18),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.filter_list,
                  size: 28,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(right: 16, left: 8, top: 18),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final role = groupedContacts.keys.elementAt(index);
                final roleContacts = groupedContacts[role]!;
                return _buildRoleSection(
                    context, role, roleContacts); // Fix parameter order
              },
              childCount: groupedContacts.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: 2, // Messages tab
        onItemSelected: (index) {},
      ),
    );
  }

  Widget _buildRoleSection(
      BuildContext context, String role, List<Contact> contacts) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  _getRoleIcon(role),
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  role,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Text(
                  '${contacts.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ...contacts.map((contact) => _buildContactTile(context, contact)),
        ],
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, Contact contact) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagesPage(
              contactName: contact.name,
              contactRole: contact.role,
              isOnline: contact.isOnline,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: contact.avatarUrl != null
                        ? NetworkImage(contact.avatarUrl!)
                        : null,
                    child: contact.avatarUrl == null
                        ? Text(
                            contact.name[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          )
                        : null,
                  ),
                ),
                if (contact.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.lastMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatLastMessageTime(contact.lastMessageTime),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastMessageTime(DateTime time) {
    // Previous time formatting logic remains the same
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'Nurse':
        return Icons.medical_services;
      case 'Nutritionist':
        return Icons.restaurant_menu;
      case 'Relative':
        return Icons.family_restroom;
      default:
        return Icons.person;
    }
  }
}
