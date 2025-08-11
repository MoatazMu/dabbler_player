import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Social'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Friends'),
              Tab(text: 'Messages'),
              Tab(text: 'Discover'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFriendsTab(),
            _buildMessagesTab(),
            _buildDiscoverTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: context.colors.primaryContainer,
            child: Icon(Icons.person, color: context.colors.onPrimaryContainer),
          ),
          title: Text('Friend ${index + 1}'),
          subtitle: Text('Last active: ${_getRandomTime()}'),
          trailing: IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              // TODO: Implement message action
            },
          ),
        );
      },
      itemCount: 10, // Placeholder count
    );
  }

  Widget _buildMessagesTab() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: context.colors.primaryContainer,
                child: Icon(Icons.person, color: context.colors.onPrimaryContainer),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Text('Chat ${index + 1}'),
          subtitle: Text('Last message: ${_getRandomTime()}'),
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.colors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: context.colors.onPrimary,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
      itemCount: 15, // Placeholder count
    );
  }

  Widget _buildDiscoverTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Player ${index + 1}',
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Interests: Sports, Gaming',
                        style: context.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement add friend action
                        },
                        child: const Text('Add Friend'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: 10, // Placeholder count
    );
  }

  String _getRandomTime() {
    final hours = (DateTime.now().hour - (DateTime.now().millisecond % 12))
        .toString()
        .padLeft(2, '0');
    final minutes =
        (DateTime.now().minute - (DateTime.now().millisecond % 60))
            .toString()
            .padLeft(2, '0');
    return '$hours:$minutes';
  }
}
