import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/game_creation_model.dart';
import '../../../core/viewmodels/game_creation_viewmodel.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/invitation_list.dart';

// --- Ant Design Button Helper ---
enum AntdButtonType { primary, defaultType, ghost }
enum AntdButtonSize { small, medium, large }

class AntdButton extends StatelessWidget {
  final AntdButtonType type;
  final AntdButtonSize size;
  final VoidCallback? onPressed;
  final Widget child;
  final bool fullWidth;

  const AntdButton({
    super.key,
    required this.type,
    required this.onPressed,
    required this.child,
    this.size = AntdButtonSize.medium,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = () {
      switch (size) {
        case AntdButtonSize.small:
          return const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
        case AntdButtonSize.large:
          return const EdgeInsets.symmetric(vertical: 18, horizontal: 32);
        case AntdButtonSize.medium:
        default:
          return const EdgeInsets.symmetric(vertical: 12, horizontal: 24);
      }
    }();
    final minWidth = fullWidth ? double.infinity : null;
    switch (type) {
      case AntdButtonType.primary:
        return SizedBox(
          width: minWidth,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: padding,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onPressed,
            child: child,
          ),
        );
      case AntdButtonType.defaultType:
        return SizedBox(
          width: minWidth,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: padding,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onPressed,
            child: child,
          ),
        );
      case AntdButtonType.ghost:
        return SizedBox(
          width: minWidth,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: padding,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onPressed,
            child: child,
          ),
        );
    }
  }
}

class PlayerInvitationStep extends StatefulWidget {
  final GameCreationViewModel viewModel;

  const PlayerInvitationStep({super.key, required this.viewModel});

  @override
  State<PlayerInvitationStep> createState() => _PlayerInvitationStepState();
}

class _PlayerInvitationStepState extends State<PlayerInvitationStep> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  String _searchQuery = '';
  bool _isLoadingContacts = false;
  List<InvitePlayer> _selectedPlayers = [];
  List<InvitePlayer> _contacts = [];
  List<InvitePlayer> _recentTeammates = [];
  List<InvitePlayer> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _messageController.text = widget.viewModel.state.invitationMessage ?? _getSimpleDefaultMessage();
    _loadMockData();
    _restoreSelectedPlayers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    _contacts = [
      InvitePlayer(id: 'c1', name: 'John Smith', email: 'john@example.com', phone: '+1234567890', source: PlayerSource.contact),
      InvitePlayer(id: 'c2', name: 'Sarah Johnson', email: 'sarah@example.com', phone: '+1234567891', source: PlayerSource.contact),
      InvitePlayer(id: 'c3', name: 'Mike Davis', email: 'mike@example.com', phone: '+1234567892', source: PlayerSource.contact),
      InvitePlayer(id: 'c4', name: 'Emily Brown', email: 'emily@example.com', phone: '+1234567893', source: PlayerSource.contact),
      InvitePlayer(id: 'c5', name: 'David Wilson', email: 'david@example.com', phone: '+1234567894', source: PlayerSource.contact),
    ];

    _recentTeammates = [
      InvitePlayer(id: 't1', name: 'Alex Rodriguez', email: 'alex@example.com', source: PlayerSource.teammate, lastPlayedDate: '2 days ago'),
      InvitePlayer(id: 't2', name: 'Lisa Chen', email: 'lisa@example.com', source: PlayerSource.teammate, lastPlayedDate: '1 week ago'),
      InvitePlayer(id: 't3', name: 'Ryan Murphy', email: 'ryan@example.com', source: PlayerSource.teammate, lastPlayedDate: '2 weeks ago'),
      InvitePlayer(id: 't4', name: 'Jessica Taylor', email: 'jessica@example.com', source: PlayerSource.teammate, lastPlayedDate: '3 weeks ago'),
    ];
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoadingContacts = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final results = [
      InvitePlayer(id: 's1', name: 'Tom Anderson', email: 'tom@example.com', source: PlayerSource.search),
      InvitePlayer(id: 's2', name: 'Maria Garcia', email: 'maria@example.com', source: PlayerSource.search),
      InvitePlayer(id: 's3', name: 'James Wilson', email: 'james@example.com', source: PlayerSource.search),
    ].where((player) => player.name.toLowerCase().contains(query.toLowerCase())).toList();

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoadingContacts = false;
      });
    }
  }

  void _togglePlayerSelection(InvitePlayer player) {
    setState(() {
      final index = _selectedPlayers.indexWhere((p) => p.id == player.id);
      if (index >= 0) {
        _selectedPlayers.removeAt(index);
      } else {
        _selectedPlayers.add(player);
      }
    });
    
    final playerIds = _selectedPlayers.map((p) => p.id).toList();
    widget.viewModel.updateSelectedPlayers(playerIds);
  }

  bool _isPlayerSelected(InvitePlayer player) {
    return _selectedPlayers.any((p) => p.id == player.id);
  }

  String _getSimpleDefaultMessage() {
    final sport = widget.viewModel.state.selectedSport ?? 'game';
    return 'Hey! I\'m organizing a $sport match. Would you like to join us? It\'s going to be fun!';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Game settings',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure who can join your game',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Participation Mode
          _buildParticipationMode(context),
          const SizedBox(height: 24),

          // Invite Players Button (only show if Private or Hybrid)
          if (widget.viewModel.state.participationMode == ParticipationMode.private || 
              widget.viewModel.state.participationMode == ParticipationMode.hybrid) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Invite Players'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: context.colors.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        left: 16,
                        right: 16,
                        top: 24,
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: InvitationList(
                          contacts: _contacts,
                          recentTeammates: _recentTeammates,
                          searchResults: _searchResults,
                          selectedPlayers: _selectedPlayers,
                          isLoadingContacts: _isLoadingContacts,
                          onPlayerToggle: _togglePlayerSelection,
                          onSearch: _performSearch,
                          onClearAll: () {
                            setState(() {
                              _selectedPlayers.clear();
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Selected Players (show as chips)
          if (_selectedPlayers.isNotEmpty) ...[
            Text(
              'Selected Players',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedPlayers.map((player) => Chip(
                label: Text(player.name.split(' ').first),
                avatar: _buildPlayerAvatar(context, player, size: 20),
                onDeleted: () => _togglePlayerSelection(player),
              )).toList(),
            ),
          ],

          // Invitation Message
          const SizedBox(height: 32),
          _buildInvitationMessage(context),
        ],
      ),
    );
  }



  Widget _buildAntdTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      indicator: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      labelColor: context.colors.onPrimary,
      unselectedLabelColor: context.colors.onSurfaceVariant,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      tabs: const [
        Tab(text: 'Contacts'),
        Tab(text: 'Teammates'),
        Tab(text: 'Search'),
      ],
    );
  }

  Widget _buildAntdPlayerTag(BuildContext context, InvitePlayer player) {
    return Chip(
      label: Text(player.name.split(' ').first),
      avatar: _buildPlayerAvatar(context, player, size: 20),
      onDeleted: () => _togglePlayerSelection(player),
      backgroundColor: context.colors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.colors.primary.withOpacity(0.2)),
      ),
      labelStyle: context.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: context.colors.primary,
      ),
      deleteIcon: Icon(LucideIcons.x, size: 16, color: context.colors.primary),
    );
  }

  Widget _buildParticipationMode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who can join?',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...ParticipationMode.values.map((mode) {
          final isSelected = widget.viewModel.state.participationMode == mode;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildParticipationOption(
              context,
              mode: mode,
              isSelected: isSelected,
              onTap: () => widget.viewModel.selectParticipationMode(mode),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildParticipationOption(
    BuildContext context, {
    required ParticipationMode mode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final modeData = _getParticipationModeData(mode);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? context.colors.primary.withOpacity(0.1)
              : context.violetWidgetBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? context.colors.primary
                : context.colors.outline.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? context.colors.primary.withOpacity(0.1)
                    : context.colors.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                modeData['icon'] as IconData,
                size: 20,
                color: isSelected 
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modeData['title'] as String,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? context.colors.primary
                          : context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    modeData['description'] as String,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                LucideIcons.check,
                size: 20,
                color: context.colors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getParticipationModeData(ParticipationMode mode) {
    switch (mode) {
      case ParticipationMode.public:
        return {
          'title': 'Public',
          'description': 'Anyone can join your game',
          'icon': LucideIcons.globe,
        };
      case ParticipationMode.private:
        return {
          'title': 'Private',
          'description': 'Only invited players can join',
          'icon': LucideIcons.lock,
        };
      case ParticipationMode.hybrid:
        return {
          'title': 'Hybrid',
          'description': 'Mix of invited players and open spots',
          'icon': LucideIcons.userPlus,
        };
    }
  }

  String _getHeaderDescription() {
    switch (widget.viewModel.state.participationMode) {
      case ParticipationMode.public:
        return 'Your game is public - anyone can join. You can still send personal invitations.';
      case ParticipationMode.private:
        return 'Only invited players can join your private game.';
      case ParticipationMode.hybrid:
        return 'Mix invited players with open spots for others to join.';
      default:
        return 'Choose who can join your game.';
    }
  }

  void _restoreSelectedPlayers() {
    final savedPlayerIds = widget.viewModel.state.selectedPlayers ?? [];
    if (savedPlayerIds.isNotEmpty) {
      final allPlayers = [..._contacts, ..._recentTeammates, ..._searchResults];
      _selectedPlayers = allPlayers.where((player) => savedPlayerIds.contains(player.id)).toList();
    }
  }

  Widget _buildNoContactsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                LucideIcons.phone,
                size: 48,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Contacts Found',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any contacts in your phone. You can still invite players by email.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(2);
                },
                icon: Icon(
                  LucideIcons.search,
                  size: 18,
                ),
                label: Text('Search Players'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Contact import feature coming soon!'),
                      backgroundColor: context.colors.primary,
                    ),
                  );
                },
                icon: Icon(
                  LucideIcons.phone,
                  size: 18,
                ),
                label: Text('Import Contacts'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  side: BorderSide(color: context.colors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTeammatesState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                LucideIcons.users,
                size: 48,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Recent Teammates',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t played with any teammates recently. Join games to build your network!',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Explore games to meet new teammates!'),
                      backgroundColor: context.colors.primary,
                    ),
                  );
                },
                icon: Icon(
                  LucideIcons.gamepad2,
                  size: 18,
                ),
                label: Text('Explore Games'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _tabController.animateTo(2);
                },
                icon: Icon(
                  LucideIcons.search,
                  size: 18,
                ),
                label: Text('Search Players'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  side: BorderSide(color: context.colors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Ant Design Tab Content Helpers ---

  Widget _buildContactsTab(BuildContext context) {
    final filteredContacts = _contacts
        .where((contact) => contact.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: Icon(LucideIcons.search, color: context.colors.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.outline.withOpacity(0.1)),
              ),
              filled: true,
              fillColor: context.violetWidgetBg,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredContacts.isEmpty
              ? _buildAntdEmptyState(context, 'No contacts found', LucideIcons.phone)
              : ListView.separated(
                  itemCount: filteredContacts.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: context.colors.outline.withOpacity(0.06)),
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return _buildAntdPlayerTile(context, contact);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTeammatesTab(BuildContext context) {
    final filteredTeammates = _recentTeammates
        .where((teammate) => teammate.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search recent teammates...',
              prefixIcon: Icon(LucideIcons.search, color: context.colors.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.outline.withOpacity(0.1)),
              ),
              filled: true,
              fillColor: context.violetWidgetBg,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredTeammates.isEmpty
              ? _buildAntdEmptyState(context, 'No recent teammates found', LucideIcons.users)
              : ListView.separated(
                  itemCount: filteredTeammates.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: context.colors.outline.withOpacity(0.06)),
                  itemBuilder: (context, index) {
                    final teammate = filteredTeammates[index];
                    return _buildAntdPlayerTile(context, teammate);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search players by name or email...',
              prefixIcon: Icon(LucideIcons.search, color: context.colors.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.outline.withOpacity(0.1)),
              ),
              filled: true,
              fillColor: context.violetWidgetBg,
            ),
            onChanged: _performSearch,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoadingContacts
              ? const Center(child: CircularProgressIndicator())
              : _searchController.text.isEmpty
                  ? _buildAntdEmptyState(context, 'Enter a name or email to search', LucideIcons.search)
                  : _searchResults.isEmpty
                      ? _buildAntdEmptyState(context, 'No players found', LucideIcons.userPlus)
                      : ListView.separated(
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: context.colors.outline.withOpacity(0.06)),
                          itemBuilder: (context, index) {
                            final player = _searchResults[index];
                            return _buildAntdPlayerTile(context, player);
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildAntdPlayerTile(BuildContext context, InvitePlayer player) {
    final isSelected = _isPlayerSelected(player);
    return ListTile(
      leading: _buildPlayerAvatar(context, player, size: 36),
      title: Text(player.name, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: player.email != null ? Text(player.email!, style: context.textTheme.bodySmall) : null,
      trailing: AntdButton(
        type: isSelected ? AntdButtonType.primary : AntdButtonType.defaultType,
        size: AntdButtonSize.small,
        onPressed: () => _togglePlayerSelection(player),
        child: isSelected ? const Icon(LucideIcons.check, size: 16) : const Icon(LucideIcons.userPlus, size: 16),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? context.colors.primary : Colors.transparent,
          width: isSelected ? 2 : 1,
        ),
      ),
      tileColor: isSelected ? context.colors.primary.withOpacity(0.06) : context.colors.surface,
      onTap: () => _togglePlayerSelection(player),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  Widget _buildAntdEmptyState(BuildContext context, String title, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 40, color: context.colors.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerAvatar(BuildContext context, InvitePlayer player, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.primary.withOpacity(0.1),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: player.avatar != null && player.avatar!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                player.avatar!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(context, player, size),
              ),
            )
          : _buildAvatarFallback(context, player, size),
    );
  }

  Widget _buildAvatarFallback(BuildContext context, InvitePlayer player, double size) {
    final initials = player.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join('').toUpperCase();
    return Center(
      child: Text(
        initials,
        style: context.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: context.colors.primary,
          fontSize: size * 0.4,
        ),
      ),
    );
  }

  Widget _buildInvitationMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Invitation message',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Customize the message sent to invited players',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _messageController,
          decoration: InputDecoration(
            hintText: 'Enter your invitation message...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.outline.withOpacity(0.1)),
            ),
            filled: true,
            fillColor: context.violetWidgetBg,
          ),
          maxLines: 3,
          onChanged: (value) => widget.viewModel.updateInvitationMessage(value),
        ),
      ],
    );
  }
} 