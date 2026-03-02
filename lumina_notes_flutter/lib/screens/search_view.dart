import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final List<String> _tabs = ['全部', '笔记', '书籍', 'AI 对话'];
  String _activeTab = '全部';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: context.read<AppState>().searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filteredNotes = state.getFilteredNotes(state.searchQuery);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, state, isDark),
            Expanded(
              child: state.searchQuery.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildResults(context, state, filteredNotes, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => state.back(),
                icon: const Icon(Icons.chevron_left, color: AppColors.primary, size: 28),
              ),
              Expanded(
                child: Text(
                  '搜索',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => state.back(),
                child: const Text('取消', style: TextStyle(color: AppColors.primary, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[500], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: _searchController,
                    onChanged: (v) => state.searchQuery = v,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: '搜索',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (state.searchQuery.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      state.searchQuery = '';
                    },
                    icon: Icon(Icons.close, size: 20, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _tabs.map((tab) {
              final isActive = _activeTab == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
                  child: Column(
                    children: [
                      Text(
                        tab,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2,
                        color: isActive ? AppColors.primary : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            '搜索笔记、书籍或 AI 对话',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    AppState state,
    List<Note> filteredNotes,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 1.2,
              ),
              children: [
                const TextSpan(text: '搜索「'),
                TextSpan(
                  text: state.searchQuery,
                  style: const TextStyle(color: AppColors.primary),
                ),
                const TextSpan(text: '」'),
              ],
            ),
          ),
        ),
        ...filteredNotes.map((note) => _NoteResultItem(
              note: note,
              onTap: () => state.openNote(note),
              isDark: isDark,
            )),
        const SizedBox(height: 24),
        _buildAiInsightsCard(state, isDark),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildAiInsightsCard(AppState state, bool isDark) {
    final filteredNotes = state.getFilteredNotes(state.searchQuery);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI 洞察',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '你有 ${filteredNotes.length} 条笔记提到了「${state.searchQuery}」，涉及多本书籍。是否生成综合摘要？',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('生成综合摘要'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteResultItem extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final bool isDark;

  const _NoteResultItem({
    required this.note,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: note.isAiGenerated
                      ? Colors.amber.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  note.isAiGenerated ? Icons.auto_awesome : Icons.description,
                  color: note.isAiGenerated ? Colors.amber[700] : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
