import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'character_models.dart';
import 'character_service.dart';
import 'character_editor.dart';
import 'character_chat_page.dart';

class CharactersPage extends StatefulWidget {
  final String selectedModel;
  
  const CharactersPage({super.key, required this.selectedModel});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> with TickerProviderStateMixin {
  final CharacterService _characterService = CharacterService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // Listen to character service changes
    _characterService.addListener(_onCharactersChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _characterService.removeListener(_onCharactersChanged);
    super.dispose();
  }

  void _onCharactersChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Character> get _filteredCharacters {
    var characters = _characterService.characters;
    
    if (_searchQuery.isNotEmpty) {
      characters = characters.where((char) =>
        char.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        char.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return characters;
  }



  void _createNewCharacter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CharacterEditor(),
      ),
    );
  }

  void _editCharacter(Character character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterEditor(character: character),
      ),
    );
  }

  void _chatWithCharacter(Character character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterChatPage(
          character: character,
          selectedModel: widget.selectedModel,
        ),
      ),
    );
  }

  void _deleteCharacter(Character character) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Character'),
        content: Text('Are you sure you want to delete "${character.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _characterService.deleteCharacter(character.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final characters = _filteredCharacters;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'AI Characters',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
              automaticallyImplyLeading: false,
            ),
            
            // Search and filter bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search characters...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Characters grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final character = characters[index];
                    
                    return _CharacterCard(
                      character: character,
                      onLongPress: () => _showCharacterOptions(character),
                      onChatTap: () => _chatWithCharacter(character),
                    );
                  },
                  childCount: characters.length,
                ),
              ),
            ),
            
            // Add some bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80), // Move above bottom navigation
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.black87, Colors.grey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _createNewCharacter,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              'New',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            extendedPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }

  void _showCharacterOptions(Character character) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(character.avatarUrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character.name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            character.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              ListTile(
                leading: const Icon(Icons.chat),
                title: Text('Chat with ${character.name}'),
                onTap: () {
                  Navigator.pop(context);
                  _chatWithCharacter(character);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Character'),
                onTap: () {
                  Navigator.pop(context);
                  _editCharacter(character);
                },
              ),
              
              if (!character.isBuiltIn) // Hide delete for built-in characters
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.black),
                  title: const Text('Delete Character', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteCharacter(character);
                  },
                ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onLongPress;
  final VoidCallback onChatTap;

  const _CharacterCard({
    required this.character,
    required this.onLongPress,
    required this.onChatTap,
  });


  @override
  Widget build(BuildContext context) {
    // Backgrounds are kept simple and neutral
    const Color backgroundColor = Colors.white;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  color: backgroundColor,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Hero(
                        tag: 'character_${character.id}',
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(character.avatarUrl),
                        ),
                      ),
                    ),
                    
                    if (character.customTag != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            character.customTag!,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Content section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Expanded(
                      child: Text(
                        character.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onChatTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Chat',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}