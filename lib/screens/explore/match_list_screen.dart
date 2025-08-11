import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/models/match_model.dart';
import '../../core/models/demo_data.dart';
import '../../themes/app_theme.dart';
import 'match_detail_screen.dart';

class MatchListScreen extends StatefulWidget {
  final String sport;
  final Color sportColor;
  final String searchQuery;

  const MatchListScreen({
    super.key,
    required this.sport,
    required this.sportColor,
    this.searchQuery = '',
  });

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  List<Match> _matches = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _matches = DemoData.getDemoMatches();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Filters
              _buildFilters(),
              
              // Match list
              Expanded(
                child: _buildMatchList(),
              ),
            ],
          );
  }

  Widget _buildFilters() {
    final filters = _getFiltersForSport();
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(
          //   '${widget.sport} Games',
          //   style: context.textTheme.titleLarge?.copyWith(
          //     fontWeight: FontWeight.w700,
          //     color: context.colors.onSurface,
          //   ),
          // ),
          // const SizedBox(height: 8),
          // Text(
          //   _getSportDescription(),
          //   style: context.textTheme.bodyMedium?.copyWith(
          //     color: context.colors.onSurfaceVariant,
          //   ),
          // ),
          // const SizedBox(height: 16),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: filters.map((filter) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: filter != filters.last ? 8 : 0,
                    ),
                    child: _buildFilterChip(filter['label'] ?? '', filter['value'] ?? ''),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getFiltersForSport() {
    switch (widget.sport.toLowerCase()) {
      case 'football':
        return [
          {'label': 'All', 'value': 'all'},
          {'label': 'Futsal', 'value': 'futsal'},
          {'label': 'Competitive', 'value': 'competitive'},
          {'label': 'Substitutional', 'value': 'substitutional'},
          {'label': 'Association', 'value': 'association'},
          {'label': 'Free', 'value': 'free'},
          {'label': 'Today', 'value': 'today'},
        ];
      case 'cricket':
        return [
          {'label': 'All', 'value': 'all'},
          {'label': 'T20', 'value': 't20'},
          {'label': 'ODI', 'value': 'odi'},
          {'label': 'Test', 'value': 'test'},
          {'label': 'Practice', 'value': 'practice'},
          {'label': 'Free', 'value': 'free'},
          {'label': 'Today', 'value': 'today'},
        ];
      case 'padel':
        return [
          {'label': 'All', 'value': 'all'},
          {'label': 'Singles', 'value': 'singles'},
          {'label': 'Doubles', 'value': 'doubles'},
          {'label': 'Free', 'value': 'free'},
          {'label': 'Today', 'value': 'today'},
        ];
      default:
        return [
          {'label': 'All', 'value': 'all'},
          {'label': 'Free', 'value': 'free'},
          {'label': 'Today', 'value': 'today'},
        ];
    }
  }

  String _getSportDescription() {
    switch (widget.sport.toLowerCase()) {
      case 'football':
        return 'Find football games and join exciting sessions';
      case 'cricket':
        return 'Discover cricket games and tournaments';
      case 'padel':
        return 'Join padel games and find players';
      default:
        return 'Find and join exciting games';
    }
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        _filterMatches();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? widget.sportColor
              : context.violetWidgetBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? widget.sportColor
                : context.colors.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected 
                ? Colors.white
                : context.colors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchList() {
    final filteredMatches = _getFilteredMatches().where((match) {
      final query = widget.searchQuery.toLowerCase();
      return query.isEmpty ||
        match.title.toLowerCase().contains(query) ||
        match.venue.name.toLowerCase().contains(query);
    }).toList();
    if (filteredMatches.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredMatches.length,
      itemBuilder: (context, index) {
        final match = filteredMatches[index];
        return _buildMatchCard(match);
      },
    );
  }

  Widget _buildMatchCard(Match match) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MatchDetailScreen(match: match),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: widget.sportColor.withValues(alpha: 0.1),
              ),
              child: Stack(
                children: [
                  if (match.venue.imageUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        match.venue.imageUrl!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  
                  // Status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(match).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(match),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  // Price badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: match.isFree 
                            ? Colors.green.withValues(alpha: 0.9)
                            : widget.sportColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        match.isFree ? 'Free' : '${match.price} EGP',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Match info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and format
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          match.title,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.sportColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          match.format.name,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: widget.sportColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Venue and time
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          match.venue.name,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatDateTime(match.startTime),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Participants and spots
                  Row(
                    children: [
                      Icon(
                        LucideIcons.users,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${match.participants.length}/${match.maxParticipants}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      if (match.spotsLeft > 0)
                        Text(
                          '${match.spotsLeft} spots left',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          'Full',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.sportColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                LucideIcons.search,
                size: 48,
                color: widget.sportColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No games found',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your filters or check back later for new games',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Match> _getFilteredMatches() {
    switch (_selectedFilter) {
      case 'futsal':
        return _matches.where((m) => m.format.name.toLowerCase().contains('futsal')).toList();
      case 'competitive':
        return _matches.where((m) => m.format.name.toLowerCase().contains('competitive')).toList();
      case 'substitutional':
        return _matches.where((m) => m.format.name.toLowerCase().contains('substitutional')).toList();
      case 'association':
        return _matches.where((m) => m.format.name.toLowerCase().contains('association')).toList();
      case 't20':
        return _matches.where((m) => m.format.name.toLowerCase().contains('t20')).toList();
      case 'odi':
        return _matches.where((m) => m.format.name.toLowerCase().contains('odi')).toList();
      case 'test':
        return _matches.where((m) => m.format.name.toLowerCase().contains('test')).toList();
      case 'practice':
        return _matches.where((m) => m.format.name.toLowerCase().contains('practice')).toList();
      case 'singles':
        return _matches.where((m) => m.format.name.toLowerCase().contains('singles')).toList();
      case 'doubles':
        return _matches.where((m) => m.format.name.toLowerCase().contains('doubles')).toList();
      case 'free':
        return _matches.where((m) => m.isFree).toList();
      case 'today':
        final today = DateTime.now();
        return _matches.where((m) => 
          m.startTime.year == today.year &&
          m.startTime.month == today.month &&
          m.startTime.day == today.day
        ).toList();
      default:
        return _matches;
    }
  }

  void _filterMatches() {
    // This method is called when filter changes
    // The filtering is done in _getFilteredMatches()
  }

  Color _getStatusColor(Match match) {
    final now = DateTime.now();
    final timeUntilMatch = match.startTime.difference(now);
    
    if (timeUntilMatch.isNegative) {
      return Colors.grey;
    } else if (timeUntilMatch.inHours < 1) {
      return Colors.red;
    } else if (timeUntilMatch.inHours < 24) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getStatusText(Match match) {
    final now = DateTime.now();
    final timeUntilMatch = match.startTime.difference(now);
    
    if (timeUntilMatch.isNegative) {
      return 'Ended';
    } else if (timeUntilMatch.inHours < 1) {
      return 'Starting Soon';
    } else if (timeUntilMatch.inHours < 24) {
      return 'Today';
    } else {
      return 'Upcoming';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final matchDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateText;
    if (matchDate == today) {
      dateText = 'Today';
    } else if (matchDate == tomorrow) {
      dateText = 'Tomorrow';
    } else {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      dateText = days[dateTime.weekday - 1];
    }
    
    final timeText = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateText at $timeText';
  }
}
