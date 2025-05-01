import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingApprovalPage extends StatelessWidget {
  final String currentUserRole;

  const PendingApprovalPage({super.key, required this.currentUserRole});

  String getTargetUserType() {
    switch (currentUserRole.toLowerCase()) {
      case 'admin':
        return 'organization';
      case 'organization':
        return 'faculty';
      case 'faculty':
        return 'student';
      default:
        return '';
    }
  }

  Future<void> handleApproval(
      BuildContext context,
      Map<String, dynamic> userData,
      String uid,
      bool isApproved,
      ) async {
    final firestore = FirebaseFirestore.instance;

    try {
      if (isApproved) {
        await firestore.collection('users').doc(uid).set({
          'email': userData['email'],
          'userType': userData['userType'],
          'status': 'approved',
          'uid': uid,
        });

        String userType = userData['userType'];
        String targetCollection =
        userType == 'organization' ? 'organizations' : 'individuals';

        await firestore.collection(targetCollection).doc(uid).set(userData);
      }

      await firestore.collection('pending_users').doc(uid).delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isApproved ? 'User approved' : 'User rejected'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  Future<void> handleBulkApproval(
      BuildContext context,
      List<QueryDocumentSnapshot> pendingDocs,
      ) async {
    final firestore = FirebaseFirestore.instance;

    try {
      for (final doc in pendingDocs) {
        final data = doc.data() as Map<String, dynamic>;
        final uid = doc.id;

        await firestore.collection('users').doc(uid).set({
          'email': data['email'],
          'userType': data['userType'],
          'status': 'approved',
          'uid': uid,
        });

        final userType = data['userType'];
        final targetCollection =
        userType == 'organization' ? 'organizations' : 'individuals';

        await firestore.collection(targetCollection).doc(uid).set(data);
        await firestore.collection('pending_users').doc(uid).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('All users approved successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Bulk approval failed: $e'),
      ));
    }
  }

  void confirmAndApproveAll(
      BuildContext context,
      List<QueryDocumentSnapshot> docs,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Approval'),
        content: Text(
            'Are you sure you want to approve all ${docs.length} ${getTargetUserType()}s?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Approve All'),
            onPressed: () {
              Navigator.pop(context);
              handleBulkApproval(context, docs);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetUserType = getTargetUserType();

    if (targetUserType.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Invalid user role')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pending ${targetUserType.capitalize()} Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pending_users')
            .where('userType', isEqualTo: targetUserType)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingDocs = snapshot.data!.docs;

          if (pendingDocs.isEmpty) {
            return Center(
              child: Text('No pending $targetUserType registrations.'),
            );
          }

          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.done_all),
                    label: const Text('Accept All'),
                    onPressed: () => confirmAndApproveAll(context, pendingDocs),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: pendingDocs.length,
                  itemBuilder: (context, index) {
                    final doc = pendingDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final uid = doc.id;

                    return Card(
                      margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(data['email'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UID: $uid'),
                            Text('User Type: ${data['userType']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  handleApproval(context, data, uid, true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  handleApproval(context, data, uid, false),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension CapExtension on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
