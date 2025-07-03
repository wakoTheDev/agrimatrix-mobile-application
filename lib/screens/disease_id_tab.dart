import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DiseaseIdTab extends StatefulWidget {
  const DiseaseIdTab({super.key});

  @override
  State<DiseaseIdTab> createState() => _DiseaseIdTabState();
}

class _DiseaseIdTabState extends State<DiseaseIdTab> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Image Upload', 'Symptom Checker', 'Disease Alerts'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tabs
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: _tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = _selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2B5320) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tab,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Tab Content
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: const [
              ImageUploadTab(),
              SymptomCheckerTab(),
              DiseaseAlertsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// Image Upload Tab
class ImageUploadTab extends StatefulWidget {
  const ImageUploadTab({super.key});

  @override
  State<ImageUploadTab> createState() => _ImageUploadTabState();
}

class _ImageUploadTabState extends State<ImageUploadTab> {
  File? _uploadedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _uploadedImage = File(image.path);
          _analysisResult = null;
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_uploadedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis delay
    await Future.delayed(const Duration(seconds: 3));

    // Mock analysis result
    setState(() {
      _isAnalyzing = false;
      _analysisResult = {
        'disease': 'Tomato Late Blight',
        'confidence': 0.89,
        'severity': 'High',
        'description': 'A fungal disease that affects tomato plants, causing dark spots on leaves and stems.',
        'treatment': [
          'Remove affected plant parts immediately',
          'Apply copper-based fungicide',
          'Improve air circulation around plants',
          'Avoid overhead watering'
        ],
        'prevention': [
          'Plant resistant varieties',
          'Ensure proper spacing between plants',
          'Water at soil level, not on leaves',
          'Apply preventive fungicide treatments'
        ]
      };
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Plant/Livestock Image',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B5320),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a clear photo of the affected plant or animal for AI-assisted diagnosis',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          
          // Image upload section
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _uploadedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _uploadedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No image selected',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B5320),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2B5320),
                    side: const BorderSide(color: Color(0xFF2B5320)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Analyze button
          if (_uploadedImage != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isAnalyzing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Analyzing...'),
                        ],
                      )
                    : const Text('Analyze Image'),
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Analysis results
          if (_analysisResult != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bug_report,
                        color: Colors.red[600],
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _analysisResult!['disease'],
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      _buildInfoChip(
                        'Confidence: ${(_analysisResult!['confidence'] * 100).toInt()}%',
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        'Severity: ${_analysisResult!['severity']}',
                        _analysisResult!['severity'] == 'High' ? Colors.red : Colors.orange,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    _analysisResult!['description'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildRecommendationSection(
                    'Treatment Recommendations',
                    _analysisResult!['treatment'],
                    Icons.healing,
                    Colors.green,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildRecommendationSection(
                    'Prevention Tips',
                    _analysisResult!['prevention'],
                    Icons.shield,
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRecommendationSection(String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 28, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

// Symptom Checker Tab
class SymptomCheckerTab extends StatefulWidget {
  const SymptomCheckerTab({super.key});

  @override
  State<SymptomCheckerTab> createState() => _SymptomCheckerTabState();
}

class _SymptomCheckerTabState extends State<SymptomCheckerTab> {
  String _selectedCrop = 'Tomato';
  final List<String> _crops = ['Tomato', 'Maize', 'Beans', 'Potato', 'Cabbage'];
  final List<String> _selectedSymptoms = [];
  final Map<String, List<String>> _symptomsByCategory = {
    'Leaves': ['Yellow spots', 'Brown spots', 'Wilting', 'Curling', 'Holes'],
    'Stems': ['Discoloration', 'Soft rot', 'Cankers', 'Stunted growth'],
    'Fruits/Seeds': ['Spots', 'Rot', 'Deformation', 'Poor development'],
    'General': ['Reduced yield', 'Plant death', 'Unusual odor'],
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Symptom-Based Diagnosis',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B5320),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your crop and symptoms to get potential diagnoses',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          
          // Crop selection
          Text(
            'Select Crop Type',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedCrop,
              isExpanded: true,
              underline: const SizedBox(),
              items: _crops.map((crop) => DropdownMenuItem(
                value: crop,
                child: Text(crop),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCrop = value!;
                  _selectedSymptoms.clear();
                });
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Symptoms selection
          Text(
            'Select Symptoms',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: ListView(
              children: _symptomsByCategory.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2B5320),
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.value.map((symptom) {
                        final isSelected = _selectedSymptoms.contains(symptom);
                        return FilterChip(
                          label: Text(symptom),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSymptoms.add(symptom);
                              } else {
                                _selectedSymptoms.remove(symptom);
                              }
                            });
                          },
                          selectedColor: const Color(0xFF2B5320).withValues(alpha: 0.2),
                          checkmarkColor: const Color(0xFF2B5320),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
          
          // Diagnose button
          if (_selectedSymptoms.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implement diagnosis logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Analyzing ${_selectedSymptoms.length} symptoms for $_selectedCrop...'),
                      backgroundColor: const Color(0xFF2B5320),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Get Diagnosis (${_selectedSymptoms.length} symptoms)'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Disease Alerts Tab
class DiseaseAlertsTab extends StatefulWidget {
  const DiseaseAlertsTab({super.key});

  @override
  State<DiseaseAlertsTab> createState() => _DiseaseAlertsTabState();
}

class _DiseaseAlertsTabState extends State<DiseaseAlertsTab> {
  final List<Map<String, dynamic>> _alerts = [
    {
      'title': 'Fall Armyworm Alert',
      'severity': 'High',
      'location': 'Kiambu County',
      'date': '2 days ago',
      'description': 'Increased fall armyworm activity reported in maize fields across Kiambu County.',
      'action': 'Monitor crops closely and apply recommended treatments',
      'icon': Icons.warning,
      'color': Colors.red,
    },
    {
      'title': 'Coffee Berry Disease',
      'severity': 'Medium',
      'location': 'Central Kenya',
      'date': '1 week ago',
      'description': 'Coffee berry disease outbreak in central Kenya region due to increased rainfall.',
      'action': 'Apply copper-based fungicides and improve drainage',
      'icon': Icons.local_drink,
      'color': Colors.orange,
    },
    {
      'title': 'Tomato Late Blight',
      'severity': 'Medium',
      'location': 'Ruiru Area',
      'date': '3 days ago',
      'description': 'Late blight conditions favorable due to humid weather conditions.',
      'action': 'Implement preventive spray programs',
      'icon': Icons.eco,
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disease Alerts & Outbreaks',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B5320),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay informed about disease outbreaks in your area',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: ListView.builder(
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              alert['icon'],
                              color: alert['color'],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                alert['title'],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: alert['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: alert['color'].withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                alert['severity'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: alert['color'],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              alert['location'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              alert['date'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          alert['description'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.blue[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Action: ${alert['action']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}