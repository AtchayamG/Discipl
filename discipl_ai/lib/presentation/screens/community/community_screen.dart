import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/common_widgets.dart';

const _allPosts = [
  {
    'id': '1', 'userName': 'Ramesh K.', 'initials': 'RK',
    'text': 'Just completed my 21-day streak! Never felt this consistent before 🔥',
    'likes': 24, 'comments': 3,
    'imageUrl': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&q=80',
    'tag': '🔥 21d', 'isTrending': false, 'isFriend': true,
    'commentList': [
      {'user': 'Priya S.', 'text': 'Incredible! Keep it up 💪'},
      {'user': 'Mohan V.', 'text': "You're an inspiration!"},
    ],
  },
  {
    'id': '2', 'userName': 'Priya S.', 'initials': 'PS',
    'text': 'Morning 5K before sunrise ☀️ Day 45 of my running journey!',
    'likes': 31, 'comments': 12,
    'imageUrl': 'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?w=600&q=80',
    'tag': '⭐ Top 10%', 'isTrending': true, 'isFriend': false,
    'commentList': [
      {'user': 'Ramesh K.', 'text': 'Wow 45 days straight! 🏅'},
      {'user': 'Arjun T.', 'text': "What's your pace?"},
    ],
  },
  {
    'id': '3', 'userName': 'Mohan V.', 'initials': 'MV',
    'text': 'Meal prepped for the week! Dropped 3kg this month 🥗',
    'likes': 19, 'comments': 6,
    'imageUrl': 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=600&q=80',
    'tag': '🏆 Leader', 'isTrending': false, 'isFriend': true,
    'commentList': [
      {'user': 'Priya S.', 'text': "What's the meal plan?"},
      {'user': 'Sneha N.', 'text': '3kg is amazing 🎉'},
    ],
  },
  {
    'id': '4', 'userName': 'Sneha N.', 'initials': 'SN',
    'text': 'New PR on deadlift — 80kg! Six months ago I could barely lift 30kg 💪',
    'likes': 42, 'comments': 15,
    'imageUrl': 'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=600&q=80',
    'tag': '💪 PR', 'isTrending': true, 'isFriend': false,
    'commentList': [
      {'user': 'Ramesh K.', 'text': 'Beast mode ON 🔥'},
      {'user': 'Mohan V.', 'text': '80kg! Absolutely crushing it'},
    ],
  },
  {
    'id': '5', 'userName': 'Arjun T.', 'initials': 'AT',
    'text': 'Yoga at sunrise — best way to start the day 🧘 Week 8 complete!',
    'likes': 28, 'comments': 9,
    'imageUrl': 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=600&q=80',
    'tag': '🧘 Zen', 'isTrending': true, 'isFriend': true,
    'commentList': [
      {'user': 'Sneha N.', 'text': 'This looks so peaceful!'},
    ],
  },
  {
    'id': '6', 'userName': 'Kavya R.', 'initials': 'KR',
    'text': 'Cycle commute + gym session today. Double win! 🚴‍♀️🏋️',
    'likes': 16, 'comments': 4,
    'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
    'tag': null, 'isTrending': false, 'isFriend': true,
    'commentList': [
      {'user': 'Arjun T.', 'text': "That's commitment!"},
    ],
  },
];

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _filterIdx = 0;
  final _filters = ['All', 'Friends', 'Trending'];
  final Set<String> _liked = {};

  List<Map<String, dynamic>> get _filtered {
    switch (_filterIdx) {
      case 1: return _allPosts.where((p) => p['isFriend'] == true).toList();
      case 2: return _allPosts.where((p) => p['isTrending'] == true).toList();
      default: return _allPosts;
    }
  }

  void _toggleLike(String id) => setState(() {
    _liked.contains(id) ? _liked.remove(id) : _liked.add(id);
  });

  void _openPost(Map<String, dynamic> post) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _PostDetailScreen(
        post: post,
        isLiked: _liked.contains(post['id']),
        onLike: () => _toggleLike(post['id'] as String),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.isLoading) return const LoadingState();
    final pad = Responsive.value<double>(context, mobile: 16, desktop: 24);

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Community', subtitle: 'Connect, share, and inspire each other'),

        // Filter tabs
        Container(
          decoration: BoxDecoration(
            color: TC.of(context).cardBg,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: TC.of(context).border),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(children: _filters.asMap().entries.map((e) {
            final isOn = e.key == _filterIdx;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _filterIdx = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isOn ? TC.of(context).lime : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(e.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFont, fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isOn ? const Color(AppColors.bg) : const Color(AppColors.textMuted),
                  )),
              ),
            ));
          }).toList()),
        ),
        const SizedBox(height: 16),

        if (_filtered.isEmpty)
          const EmptyState(emoji: '🏋️', title: 'No posts yet', subtitle: 'Nothing here yet — check back soon')
        else
          Column(children: _filtered.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PostCard(
              post: p,
              isLiked: _liked.contains(p['id']),
              onLike: () => _toggleLike(p['id'] as String),
              onTap: () => _openPost(p),
            ),
          )).toList()),

        const SizedBox(height: 32),
      ]),
    );
  }
}

// ─── Post card ────────────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool isLiked;
  final VoidCallback onLike, onTap;
  const _PostCard({required this.post, required this.isLiked, required this.onLike, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name     = post['userName'] as String? ?? 'User';
    final text     = post['text'] as String? ?? '';
    final likes    = (post['likes'] as int? ?? 0) + (isLiked ? 1 : 0);
    final comments = post['comments'] as int? ?? 0;
    final imageUrl = post['imageUrl'] as String?;
    final tag      = post['tag'] as String?;
    final isTrending = post['isTrending'] as bool? ?? false;
    final initials = post['initials'] as String? ?? name.substring(0, 1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: TC.of(context).cardBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: TC.of(context).border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
              child: imageUrl != null
                  ? Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _Fallback(initials: initials),
                      loadingBuilder: (_, child, prog) => prog == null ? child
                          : Container(height: 180, color: TC.of(context).cardBg2,
                              child: Center(child: CircularProgressIndicator(
                                  strokeWidth: 2, color: TC.of(context).lime))))
                  : _Fallback(initials: initials),
            ),
            if (isTrending)
              Positioned(top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.orange).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('↑ Trending', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                )),
            Positioned(bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xDD000000)]),
                ),
                child: Row(children: [
                  CircleAvatar(radius: 12,
                    backgroundColor: const Color(AppColors.limeAlpha20),
                    child: Text(initials, style: TextStyle(
                      fontFamily: AppTypography.displayFont, fontSize: 9,
                      fontWeight: FontWeight.w700, color: TC.of(context).lime))),
                  const SizedBox(width: 6),
                  Expanded(child: Text(name, style: const TextStyle(
                    fontFamily: AppTypography.displayFont, fontSize: 11,
                    fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis)),
                  if (tag != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.bg).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: TC.of(context).limeBorder),
                      ),
                      child: Text(tag, style: TextStyle(fontSize: 9, color: TC.of(context).lime))),
                ]),
              )),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(text, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 12,
                      color: TC.of(context).textMuted, height: 1.5)),
              const SizedBox(height: 8),
              Row(children: [
                GestureDetector(onTap: onLike, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 18,
                        color: isLiked ? Colors.red : const Color(AppColors.textMuted)),
                    const SizedBox(width: 5),
                    Text('$likes', style: TextStyle(fontFamily: AppTypography.bodyFont, fontSize: 13,
                        color: isLiked ? Colors.red : const Color(AppColors.textMuted))),
                  ]),
                )),
                GestureDetector(onTap: onTap, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.chat_bubble_outline, size: 18, color: TC.of(context).textMuted),
                    const SizedBox(width: 5),
                    Text('$comments', style: TextStyle(fontFamily: AppTypography.bodyFont,
                        fontSize: 13, color: TC.of(context).textMuted)),
                  ]),
                )),
                const Spacer(),
                _ShareButton(text: text),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ShareButton extends StatefulWidget {
  final String text;
  const _ShareButton({required this.text});
  @override State<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<_ShareButton> {
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await Share.share(widget.text);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _share,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Icon(Icons.ios_share_outlined, size: 18,
          color: _sharing ? const Color(AppColors.lime) : const Color(AppColors.textMuted)),
    ),
  );
}

class _Fallback extends StatelessWidget {
  final String initials;
  const _Fallback({required this.initials});
  @override
  Widget build(BuildContext context) => Container(height: 180, width: double.infinity,
    color: TC.of(context).cardBg2,
    child: Center(child: Text(initials,
      style: TextStyle(fontSize: 48, color: const Color(AppColors.lime).withOpacity(0.3)))));
}

// ─── Post detail screen ───────────────────────────────────────────────────────
class _PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool isLiked;
  final VoidCallback onLike;
  const _PostDetailScreen({required this.post, required this.isLiked, required this.onLike});
  @override
  State<_PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<_PostDetailScreen> {
  late bool _liked;
  bool _sharing = false;
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollCtrl = ScrollController();
  late List<Map<String, dynamic>> _comments;

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _comments = List<Map<String, dynamic>>.from(
      (widget.post['commentList'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? []);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // Dismiss keyboard and unfocus before popping — prevents numeric keyboard
  // from bleeding into the parent community screen on back navigation.
  void _goBack() {
    _focusNode.unfocus();
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }

  void _submit() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _comments.add({'user': 'You', 'text': t});
      _ctrl.clear();
    });
    // Dismiss keyboard after sending
    _focusNode.unfocus();
    FocusScope.of(context).unfocus();
    // Scroll to bottom after frame renders so new comment is visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final post     = widget.post;
    final name     = post['userName'] as String? ?? 'User';
    final text     = post['text'] as String? ?? '';
    final likes    = (post['likes'] as int? ?? 0) + (_liked ? 1 : 0);
    final imageUrl = post['imageUrl'] as String?;
    final tag      = post['tag'] as String?;
    final initials = post['initials'] as String? ?? name.substring(0, 1);

    return Scaffold(
      // resizeToAvoidBottomInset:true shifts the whole body up when keyboard opens
      resizeToAvoidBottomInset: true,
      backgroundColor: TC.of(context).pageBg,
      appBar: AppBar(
        backgroundColor: TC.of(context).cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: TC.of(context).textPrimary,
          // Use _goBack to dismiss keyboard + unfocus before leaving
          onPressed: _goBack,
        ),
        title: Text(name, style: TextStyle(fontFamily: AppTypography.displayFont,
            fontSize: 16, fontWeight: FontWeight.w700, color: TC.of(context).textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined, size: 18),
            color: _sharing ? const Color(AppColors.lime) : const Color(AppColors.textMuted),
            onPressed: _sharing ? null : () async {
              setState(() => _sharing = true);
              try { await Share.share(text); } finally {
                if (mounted) setState(() => _sharing = false);
              }
            },
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            // Tap outside comment box dismisses keyboard
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(children: [
              if (imageUrl != null)
                Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _Fallback(initials: initials),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Author row
                  Row(children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(AppColors.limeAlpha20),
                      child: Text(initials, style: TextStyle(
                          fontFamily: AppTypography.displayFont,
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: TC.of(context).lime)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(name, style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: TC.of(context).textPrimary))),
                    if (tag != null) DPill(tag),
                  ]),
                  const SizedBox(height: 12),
                  Text(text, style: TextStyle(
                      fontFamily: AppTypography.bodyFont,
                      fontSize: 14, color: TC.of(context).textMuted, height: 1.6)),
                  const SizedBox(height: 14),
                  // Like / comment counts
                  Row(children: [
                    GestureDetector(
                      onTap: () { setState(() => _liked = !_liked); widget.onLike(); },
                      child: Row(children: [
                        Icon(_liked ? Icons.favorite : Icons.favorite_border,
                            size: 18, color: _liked ? Colors.red : const Color(AppColors.textMuted)),
                        const SizedBox(width: 4),
                        Text('$likes', style: TextStyle(
                            fontSize: 13,
                            color: _liked ? Colors.red : const Color(AppColors.textMuted))),
                      ]),
                    ),
                    const SizedBox(width: 16),
                    Row(children: [
                      Icon(Icons.chat_bubble_outline, size: 16, color: TC.of(context).textMuted),
                      const SizedBox(width: 4),
                      Text('${_comments.length}', style: TextStyle(
                          fontSize: 13, color: TC.of(context).textMuted)),
                    ]),
                  ]),
                  const SizedBox(height: 20),
                  Divider(color: TC.of(context).border),
                  const SizedBox(height: 12),
                  Text('Comments (${_comments.length})', style: TextStyle(
                      fontFamily: AppTypography.displayFont,
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: TC.of(context).textPrimary)),
                  const SizedBox(height: 10),
                  // Comments list
                  ..._comments.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: c['user'] == 'You'
                            ? const Color(AppColors.limeAlpha20)
                            : TC.of(context).surfaceBg,
                        child: Text(
                          (c['user'] as String).substring(0, 1),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: c['user'] == 'You'
                                ? TC.of(context).lime
                                : TC.of(context).textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c['user'] as String, style: TextStyle(
                            fontFamily: AppTypography.displayFont,
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: TC.of(context).textPrimary)),
                        const SizedBox(height: 2),
                        Text(c['text'] as String, style: TextStyle(
                            fontFamily: AppTypography.bodyFont,
                            fontSize: 13, color: TC.of(context).textMuted, height: 1.4)),
                      ])),
                    ]),
                  )),
                  // Bottom padding so last comment is not hidden behind input bar
                  const SizedBox(height: 8),
                ]),
              ),
            ]),
          ),
        ),

        // ── Comment input bar ──────────────────────────────────────────────
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: TC.of(context).cardBg,
              border: Border(top: BorderSide(color: TC.of(context).border)),
            ),
            child: Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: TC.of(context).cardBg2,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: TC.of(context).border),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focusNode,
                    // Force text keyboard — prevents numeric keyboard bleeding from
                    // other screens staying in keyboard memory
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    style: TextStyle(fontSize: 13, color: TC.of(context).textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: TC.of(context).textMuted, fontSize: 13),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: TC.of(context).lime, shape: BoxShape.circle),
                  child: Icon(Icons.send_rounded, size: 16, color: TC.of(context).checkFg),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
