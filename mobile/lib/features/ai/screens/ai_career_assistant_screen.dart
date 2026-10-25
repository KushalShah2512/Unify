import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

class AiCareerAssistantScreen extends StatefulWidget {
  const AiCareerAssistantScreen({super.key});

  @override
  State<AiCareerAssistantScreen> createState() => _AiCareerAssistantScreenState();
}

class _AiCareerAssistantScreenState extends State<AiCareerAssistantScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  // Chat State
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'ai',
      'text':
          'Hello! I am your **Unify AI Career Coach** 🤖\n\nI can help you review your resume structure, build personalized learning roadmaps, and assess your opportunity readiness.\n\nYou can also switch to the **Mock Interview** tab above to practice live technical and behavioral interview rounds with real-time scoring!',
    }
  ];
  bool _isChatLoading = false;

  final List<String> _quickPrompts = [
    '🎯 Mock Interview Questions',
    '📄 How can I improve my resume?',
    '🚀 Career roadmap for my goal',
    '💡 Projects to stand out',
  ];

  // Mock Interview Simulator State
  String _selectedRole = 'Full Stack Developer';
  String _selectedType = 'technical';
  bool _isInterviewActive = false;
  bool _isInterviewLoading = false;
  int _interviewQuestionNumber = 1;
  String _currentQuestion = '';
  final TextEditingController _answerController = TextEditingController();

  // Last evaluation
  Map<String, dynamic>? _lastEvaluation;
  final List<Map<String, dynamic>> _interviewHistory = [];
  bool _isInterviewCompleted = false;
  String? _overallSummary;

  final List<String> _availableRoles = [
    'Full Stack Developer',
    'Frontend Developer',
    'Backend Engineer',
    'Mobile App Developer (Flutter)',
    'Data Analyst / Scientist',
    'Cloud / DevOps Engineer',
    'Product Management',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  // ==========================================
  // Chat Actions
  // ==========================================
  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _messageController.text.trim();
    if (text.isEmpty || _isChatLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isChatLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _apiService.careerChat(message: text);
      final reply = response.data['reply'] as String? ?? 'No response received.';

      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'text': reply});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'text':
                '⚠️ Sorry, I encountered an issue connecting to the AI service. Please check your connection and try again.',
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isChatLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ==========================================
  // Mock Interview Actions
  // ==========================================
  Future<void> _startMockInterview() async {
    setState(() {
      _isInterviewLoading = true;
      _interviewHistory.clear();
      _lastEvaluation = null;
      _isInterviewCompleted = false;
      _overallSummary = null;
    });

    try {
      final res = await _apiService.conductMockInterview(
        role: _selectedRole,
        type: _selectedType,
        currentQuestionNumber: 1,
      );

      final interview = res.data['interview'] as Map<String, dynamic>;
      setState(() {
        _isInterviewActive = true;
        _interviewQuestionNumber = interview['questionNumber'] ?? 1;
        _currentQuestion = interview['question'] ?? 'Tell me about yourself and your technical interests.';
        _answerController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize mock interview: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isInterviewLoading = false);
    }
  }

  Future<void> _submitInterviewAnswer() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty || _isInterviewLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your answer before submitting.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isInterviewLoading = true);

    try {
      final res = await _apiService.conductMockInterview(
        role: _selectedRole,
        type: _selectedType,
        currentQuestionNumber: _interviewQuestionNumber,
        previousQuestion: _currentQuestion,
        candidateAnswer: answer,
      );

      final interview = res.data['interview'] as Map<String, dynamic>;
      final isCompleted = interview['isCompleted'] == true;

      setState(() {
        _lastEvaluation = {
          'question': _currentQuestion,
          'answer': answer,
          'score': interview['score'],
          'strengths': interview['strengths'],
          'improvementAreas': interview['improvementAreas'],
          'idealAnswer': interview['idealAnswer'],
        };
        _interviewHistory.add(_lastEvaluation!);

        if (isCompleted) {
          _isInterviewCompleted = true;
          _overallSummary = interview['overallSummary'] ??
              'Outstanding performance! You completed the full 5-question interview simulation.';
          _isInterviewActive = false;
        } else {
          _interviewQuestionNumber = interview['nextQuestionNumber'] ?? (_interviewQuestionNumber + 1);
          _currentQuestion = interview['nextQuestion'] ?? '';
          _answerController.clear();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to evaluate answer: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isInterviewLoading = false);
    }
  }

  void _resetInterview() {
    setState(() {
      _isInterviewActive = false;
      _isInterviewCompleted = false;
      _interviewHistory.clear();
      _lastEvaluation = null;
      _answerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Career Hub',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Gemini AI Powered',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF94A3B8),
          tabs: const [
            Tab(
              icon: Icon(Icons.chat_bubble_outline, size: 18),
              text: 'Career Coach',
            ),
            Tab(
              icon: Icon(Icons.psychology, size: 18),
              text: 'Mock Interview',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildMockInterviewTab(),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: AI Career Coach Chat
  // ==========================================
  Widget _buildChatTab() {
    return Column(
      children: [
        // Quick Prompts Bar
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _quickPrompts.length,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return ActionChip(
                label: Text(
                  _quickPrompts[index],
                  style: const TextStyle(fontSize: 12, color: Color(0xFFE2E8F0)),
                ),
                backgroundColor: const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFF334155)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: _isChatLoading ? null : () => _sendMessage(_quickPrompts[index]),
              );
            },
          ),
        ),

        // Messages List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['role'] == 'user';

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.82,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF4F46E5) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isUser ? const Color(0xFF6366F1) : const Color(0xFF334155),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, size: 14, color: Color(0xFFA855F7)),
                            const SizedBox(width: 4),
                            Text(
                              'Unify Assistant',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade200,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        msg['text'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (_isChatLoading)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Coach is crafting your response...',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),

        // Message Input Field
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            border: Border(
              top: BorderSide(color: Color(0xFF334155)),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Ask career advice, interview questions...',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isChatLoading ? null : () => _sendMessage(),
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: Interactive AI Mock Interviewer
  // ==========================================
  Widget _buildMockInterviewTab() {
    if (_isInterviewCompleted) {
      return _buildCompletedView();
    }

    if (_isInterviewActive) {
      return _buildActiveInterviewView();
    }

    return _buildSetupInterviewView();
  }

  // Setup / Start View
  Widget _buildSetupInterviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.videocam, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Mock Interview Simulator',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Practice multi-round questions with real-time feedback & scoring',
                            style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FeaturePoint(icon: Icons.check_circle_outline, text: '5 Custom Questions'),
                    _FeaturePoint(icon: Icons.speed, text: 'Scored out of 10'),
                    _FeaturePoint(icon: Icons.lightbulb_outline, text: 'Model Answers'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Target Job Role',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF818CF8)),
                items: _availableRoles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'Interview Focus Round',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildRoundTypeOption('Technical', 'technical', Icons.code),
              const SizedBox(width: 10),
              _buildRoundTypeOption('Behavioral', 'behavioral', Icons.record_voice_over),
              const SizedBox(width: 10),
              _buildRoundTypeOption('Mixed', 'mixed', Icons.shuffle),
            ],
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isInterviewLoading ? null : _startMockInterview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              child: _isInterviewLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Begin Mock Interview Session',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundTypeOption(String label, String value, IconData icon) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4F46E5).withValues(alpha: 0.25) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF334155),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF94A3B8), size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Active Simulation View
  Widget _buildActiveInterviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6366F1)),
                ),
                child: Text(
                  'Question $_interviewQuestionNumber of 5',
                  style: const TextStyle(
                    color: Color(0xFF818CF8),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _resetInterview,
                icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                label: const Text('Exit Session', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress indicator bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _interviewQuestionNumber / 5.0,
              backgroundColor: const Color(0xFF334155),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),

          // Interviewer Prompt Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF6366F1),
                      child: Icon(Icons.person, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Interviewer ($_selectedRole)',
                      style: const TextStyle(
                        color: Color(0xFF818CF8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _currentQuestion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Last answer critique card (if available)
          if (_lastEvaluation != null) ...[
            const SizedBox(height: 16),
            _buildCritiqueCard(_lastEvaluation!),
          ],

          const SizedBox(height: 16),
          const Text(
            'Your Answer:',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Candidate Answer Text Area
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF475569)),
            ),
            child: TextField(
              controller: _answerController,
              maxLines: 6,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
              decoration: const InputDecoration(
                hintText: 'Type your answer clearly. Include practical context, key technical principles, and results...',
                hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isInterviewLoading ? null : _submitInterviewAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isInterviewLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _interviewQuestionNumber == 5 ? 'Submit Final Answer & Get Report' : 'Submit Answer & Next Question',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCritiqueCard(Map<String, dynamic> eval) {
    final score = eval['score'] ?? 7;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Feedback on Previous Question',
                style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Score: $score/10',
                  style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '✅ Strengths: ${eval['strengths'] ?? 'Good direct answer.'}',
            style: const TextStyle(color: Color(0xFF86EFAC), fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 4),
          Text(
            '💡 Improvement: ${eval['improvementAreas'] ?? 'Provide more concrete examples.'}',
            style: const TextStyle(color: Color(0xFFFDE047), fontSize: 12, height: 1.3),
          ),
        ],
      ),
    );
  }

  // Completed Session Report View
  Widget _buildCompletedView() {
    double totalScore = 0;
    for (var item in _interviewHistory) {
      totalScore += (item['score'] as num? ?? 7).toDouble();
    }
    final avgScore = _interviewHistory.isNotEmpty
        ? (totalScore / _interviewHistory.length).toStringAsFixed(1)
        : '8.0';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF047857).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFBBF24), size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Interview Simulation Completed!',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Target Role: $_selectedRole',
                  style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 13),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Average Score: $avgScore / 10',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          if (_overallSummary != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Interviewer Evaluation & Key Takeaways',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _overallSummary!,
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _resetInterview,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Start Another Mock Interview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeaturePoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF818CF8), size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFFE0E7FF), fontSize: 11),
        ),
      ],
    );
  }
}
