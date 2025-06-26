import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import 'package:dr_crop/pages/login_page.dart';
import 'dart:io';

void main() {
  runApp(const DrCropApp());
}

class DrCropApp extends StatelessWidget {
  const DrCropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DrCropHome(),
    );
  }
}

class DrCropHome extends StatefulWidget {
  const DrCropHome({super.key});

  @override
  _DrCropHomeState createState() => _DrCropHomeState();
}

class _DrCropHomeState extends State<DrCropHome> {
  File? _selectedImage;
  User? user;
  // MY CODE
  File? _image;
  Interpreter? _interpreter;
  Map<String,dynamic>? _result;
  String? Solution;




  final List<String> _classnames = [
    'Apple black rot', 'Apple healthy', 'Apple rust', 'Apple scab',
    'Cassava bacterial blight', 'Cassava brown streak disease',
    'Cassava green mottle', 'Cassava healthy', 'Cassava mosaic disease',
    'Cherry healthy', 'Cherry powdery mildew', 'Chili healthy',
    'Chili leaf curl', 'Chili leaf spot', 'Chili whitefly', 'Chili yellowish',
    'Coffee cercospora leaf spot', 'Coffee healthy', 'Coffee red spider mite', 'Coffee rust',
    'Corn common rust', 'Corn gray leaf spot', 'Corn healthy', 'Corn northern leaf blight',
    'Cucumber diseased', 'Cucumber healthy', 'Gauva diseased', 'Gauva healthy',
    'Grape black measles', 'Grape black rot', 'Grape healthy',
    'Grape leaf blight (isariopsis leaf spot)', 'Jamun diseased', 'Jamun healthy',
    'Lemon diseased', 'Lemon healthy', 'Mango diseased', 'Mango healthy',
    'Peach bacterial spot', 'Peach healthy', 'Pepper bell bacterial spot',
    'Pepper bell healthy', 'Pomegranate diseased', 'Pomegranate healthy',
    'Potato early blight', 'Potato healthy', 'Potato late blight',
    'Rice brown spot', 'Rice healthy', 'Rice hispa', 'Rice leaf blast',
    'Rice neck blast', 'Soybean bacterial blight', 'Soybean caterpillar',
    'Soybean diabrotica speciosa', 'Soybean downy mildew', 'Soybean healthy',
    'Soybean mosaic virus', 'Soybean powdery mildew', 'Soybean rust',
    'Soybean southern blight', 'Strawberry leaf scorch', 'Strawberry healthy',
    'Sugarcane bacterial blight', 'Sugarcane healthy', 'Sugarcane red rot',
    'Sugarcane red stripe', 'Sugarcane rust', 'Tea algal leaf', 'Tea anthracnose',
    'Tea bird eye spot', 'Tea brown blight', 'Tea healthy', 'Tea red leaf spot',
    'Tomato bacterial spot', 'Tomato early blight', 'Tomato healthy',
    'Tomato late blight', 'Tomato leaf mold', 'Tomato mosaic virus',
    'Tomato septoria leaf spot', 'Tomato spider mites (two spotted spider mite)',
    'Tomato target spot', 'Tomato yellow leaf curl virus', 'Wheat brown rust',
    'Wheat healthy', 'Wheat septoria', 'Wheat yellow rust'
  ];

  Map<String, String> plantDiseaseSolutions = {
    'Apple black rot': '''
   Cause: Fungal infection (Botryosphaeria obtusa).
   Symptoms: Dark, circular spots on fruit, cankers on branches.
   Treatment: Prune infected branches, apply fungicides (copperbased), remove fallen fruit.
   Prevention: Good orchard sanitation, proper spacing, fungicide sprays during bloom.
''',
    'Apple healthy': 'Healthy apple tree, no specific treatment needed.',
    'Apple rust': '''
   Cause: Fungal infection (Gymnosporangium juniperivirginianae).
   Symptoms: Yellow spots on leaves, orange lesions on fruit.
   Treatment: Remove cedar trees (alternate host), apply fungicides.
   Prevention: Cedar removal, fungicide applications before symptoms appear.
''',
    'Apple scab': '''
   Cause: Fungal infection (Venturia inaequalis).
   Symptoms: Olivegreen to brown spots on leaves and fruit.
   Treatment: Apply fungicides (captan, myclobutanil), remove fallen leaves.
   Prevention: Resistant cultivars, fungicide sprays, good air circulation.
''',
    'Cassava bacterial blight': '''
   Cause: Bacterial infection (Xanthomonas axonopodis pv. manihotis).
   Symptoms: Angular leaf spots, wilting, stem lesions.
   Treatment: Use diseasefree planting material, sanitize tools, remove infected plants.
   Prevention: Resistant varieties, crop rotation, avoid wounding plants.
''',
    'Cassava brown streak disease': '''
   Cause: Cassava brown streak virus (CBSV).
   Symptoms: Yellowing leaves, root necrosis, stem lesions.
   Treatment: Use diseasefree planting material, remove infected plants.
   Prevention: Resistant varieties, vector control (whiteflies).
''',
    'Cassava green mottle': '''
   Cause: Cassava green mottle virus (CGMV).
   Symptoms: Green mosaic pattern on leaves, leaf distortion.
   Treatment: Use diseasefree planting material, remove infected plants.
   Prevention: Resistant varieties, vector control (whiteflies).
''',
    'Cassava healthy': 'Healthy cassava plant, no specific treatment needed.',
    'Cassava mosaic disease': '''
   Cause: Cassava mosaic begomoviruses (CMBs).
   Symptoms: Mosaic pattern on leaves, leaf distortion, stunted growth.
   Treatment: Use diseasefree planting material, remove infected plants.
   Prevention: Resistant varieties, vector control (whiteflies).
''',
    'Cherry healthy': 'Healthy cherry tree, no specific treatment needed.',
    'Cherry powdery mildew': '''
   Cause: Fungal infection (Podosphaera clandestina).
   Symptoms: White powdery growth on leaves and fruit.
   Treatment: Apply fungicides (sulfurbased), prune for air circulation.
   Prevention: Resistant varieties, fungicide sprays.
''',
    'Chili healthy': 'Healthy chili plant, no specific treatment needed.',
    'Chili leaf curl': '''
   Cause: Chili leaf curl virus (ChiLCV).
   Symptoms: Leaf curling, vein swelling, stunted growth.
   Treatment: Remove infected plants, vector control (whiteflies).
   Prevention: Resistant varieties, vector control, good sanitation.
''',
    'Chili leaf spot': '''
   Cause: Fungal infection (Cercospora capsici).
   Symptoms: Circular spots on leaves, yellowing.
   Treatment: Apply fungicides (chlorothalonil), remove infected leaves.
   Prevention: Crop rotation, good sanitation, fungicide sprays.
''',
    'Chili whitefly': '''
   Cause: Insect infestation (Bemisia tabaci).
   Symptoms: Yellowing leaves, honeydew, sooty mold.
   Treatment: Insecticidal soaps, neem oil, biological control.
   Prevention: Monitor plants, introduce natural enemies.
''',
    'Chili yellowish': '''
   Cause: Various factors, including nutrient deficiencies, viral infections, or environmental stress.
   Symptoms: Yellowing leaves, stunted growth.
   Treatment: Address underlying cause (fertilize, treat infection, improve conditions).
   Prevention: Proper fertilization, diseaseresistant varieties, good growing conditions.
''',
    'Coffee cercospora leaf spot': '''
   Cause: Fungal infection (Cercospora coffeicola).
   Symptoms: Circular brown spots on leaves, defoliation.
   Treatment: Apply copperbased fungicides, prune for air circulation.
   Prevention: Shade management, fungicide sprays, proper spacing.
''',
    'Coffee healthy': 'Healthy coffee plant, no specific treatment needed.',
    'Coffee red spider mite': '''
   Cause: Mite infestation (Oligonychus coffeae).
   Symptoms: Yellowing leaves, webbing, reduced growth.
   Treatment: Miticides, neem oil, biological control.
   Prevention: Monitor plants, introduce natural enemies.
''',
    'Coffee rust': '''
   Cause: Fungal infection (Hemileia vastatrix).
   Symptoms: Orange powdery pustules on leaves, defoliation.
   Treatment: Apply copperbased fungicides, resistant varieties.
   Prevention: Resistant varieties, fungicide sprays, shade management.
''',
    'Corn common rust': '''
   Cause: Fungal infection (Puccinia sorghi).
   Symptoms: Orange to reddishbrown pustules on leaves.
   Treatment: Apply fungicides (triazoles), resistant varieties.
   Prevention: Resistant varieties, crop rotation, fungicide sprays.
''',
    'Corn gray leaf spot': '''
   Cause: Fungal infection (Cercospora zeaemaydis).
   Symptoms: Gray to brown rectangular lesions on leaves.
   Treatment: Apply fungicides (strobilurins), resistant varieties.
   Prevention: Resistant varieties, crop rotation, tillage.
''',
    'Corn healthy': 'Healthy corn plant, no specific treatment needed.',
    'Corn northern leaf blight': '''
   Cause: Fungal infection (Setosphaeria turcica).
   Symptoms: Elliptical gray to tan lesions on leaves.
   Treatment: Apply fungicides (strobilurins), resistant varieties.
   Prevention: Resistant varieties, crop rotation, tillage.
''',
    'Cucumber diseased': '''
   Cause: Various diseases (powdery mildew, downy mildew, bacterial wilt).
   Symptoms: Wilting, spots on leaves, fruit rot.
   Treatment: Address specific disease (fungicides, bactericides, resistant varieties).
   Prevention: Good sanitation, resistant varieties, proper spacing.
''',
    'Cucumber healthy': 'Healthy cucumber plant, no specific treatment needed.',
    'Gauva diseased': '''
   Cause: Various diseases (anthracnose, fruit rot, wilt).
   Symptoms: Spots on fruit and leaves, wilting.
   Treatment: Address specific disease (fungicides, sanitation).
   Prevention: Good sanitation, proper spacing, fungicide sprays.
''',
    'Gauva healthy': 'Healthy guava plant, no specific treatment needed.',
    'Grape black measles': '''
   Cause: Fungal infection (Phaeomoniella chlamydospora, Phaeoacremonium aleophilum).
   Symptoms: Dark spots on canes, leaf discoloration, stunted growth.
   Treatment: Prune infected wood, apply fungicides.
   Prevention: Good sanitation, resistant varieties, proper pruning.
''',
    'Grape black rot': '''
   Cause: Fungal infection (Guignardia bidwellii).
   Symptoms: Black spots on leaves and fruit, fruit rot.
   Treatment: Apply fungicides (captan, myclobutanil), remove infected fruit.
   Prevention: Good sanitation, fungicide sprays, proper spacing.
''',
    'Grape healthy': 'Healthy grape vine, no specific treatment needed.',
    'Grape leaf blight (isariopsis leaf spot)': '''
   Cause: Fungal infection (Isariopsis clavispora).
   Symptoms: Brown spots on leaves, defoliation.
   Treatment: Apply fungicides (copperbased), remove infected leaves.
   Prevention: Good sanitation, fungicide sprays, proper spacing.
''',
    'Jamun diseased': '''
   Cause: Various diseases (anthracnose, leaf spot).
   Symptoms: Spots on leaves and fruit, wilting.
   Treatment: Address specific disease (fungicides, sanitation).
   Prevention: Good sanitation, proper care.
''',
    'Jamun healthy': 'Healthy jamun tree, no specific treatment needed.',
    'Lemon diseased': '''
   Cause: Various diseases (citrus canker, greasy spot, phytophthora).
   Symptoms: Spots on leaves and fruit, dieback, root rot.
   Treatment: Address specific disease (copper fungicides, sanitation, proper drainage).
   Prevention: Good sanitation, proper care, diseasefree seedlings.
''',
    'Lemon healthy': 'Healthy lemon tree, no specific treatment needed.',
    'Mango diseased': '''
   Cause: Various diseases (anthracnose, powdery mildew, scab).
   Symptoms: Spots on fruit and leaves, blossom blight.
   Treatment: Address specific disease (fungicides, sanitation).
   Prevention: Good sanitation, proper care, fungicide sprays.
''',
    'Mango healthy': 'Healthy mango tree, no specific treatment needed.',
    'Peach bacterial spot': '''
   Cause: Bacterial infection (Xanthomonas campestris pv. pruni).
   Symptoms: Dark spots on leaves and fruit, defoliation.
   Treatment: Apply copper fungicides, prune infected branches.
   Prevention: Good sanitation, resistant varieties, proper pruning.
''',
    'Peach healthy': 'Healthy peach tree, no specific treatment needed.',
    'Pepper bell bacterial spot': '''
   Cause: Bacterial infection (Xanthomonas vesicatoria).
   Symptoms: Watersoaked spots on leaves and fruit.
   Treatment: Apply copper fungicides, remove infected plants.
   Prevention: Good sanitation, crop rotation, diseasefree seedlings.
''',
    'Pepper bell healthy': 'Healthy pepper bell plant, no specific treatment needed.',
    'Pomegranate diseased': '''
   Cause: Various diseases (fruit rot, leaf spot, wilt).
   Symptoms: Spots on fruit and leaves, wilting.
   Treatment: Address specific disease (fungicides, sanitation).
   Prevention: Good sanitation, proper care, fungicide sprays.
''',
    'Pomegranate healthy': 'Healthy pomegranate tree, no specific treatment needed.',
    'Potato early blight': '''
   Cause: Fungal infection (Alternaria solani).
   Symptoms: Dark spots on leaves, targetlike lesions.
   Treatment: Apply chlorothalonil or mancozeb fungicides.
   Prevention: Crop rotation, good sanitation, resistant varieties.
''',
    'Potato healthy': 'Healthy potato plant, no specific treatment needed.',
    'Potato late blight': '''
   Cause: Oomycete infection (Phytophthora infestans).
   Symptoms: Watersoaked lesions on leaves and tubers.
   Treatment: Apply mancozeb or chlorothalonil fungicides.
   Prevention: Good sanitation, resistant varieties, timely sprays.
''',
    'Rice brown spot': '''
   Cause: Fungal infection (Bipolaris oryzae).
   Symptoms: Brown spots on leaves and grains.
   Treatment: Apply fungicides, improve soil health.
   Prevention: Seed treatment, balanced fertilization, crop rotation.
''',
    'Rice healthy': 'Healthy rice plant, no specific treatment needed.',
    'Rice hispa': '''
   Cause: Insect infestation (Dicladispa armigera).
   Symptoms: White streaks on leaves, damaged leaves.
   Treatment: Apply insecticides, remove infested leaves.
   Prevention: Monitor, biological control, proper water management.
''',
    'Rice leaf blast': '''
   Cause: Fungal infection (Magnaporthe oryzae).
   Symptoms: Diamondshaped lesions on leaves.
   Treatment: Apply triazole fungicides, use resistant varieties.
   Prevention: Balanced fertilization, proper spacing, resistant cultivars.
''',
    'Rice neck blast': '''
   Cause: Fungal infection (Magnaporthe oryzae).
   Symptoms: Lesions on the neck of the panicle.
   Treatment: Apply triazole fungicides, use resistant varieties.
   Prevention: Balanced fertilization, proper spacing, resistant cultivars.
''',
    'Soybean bacterial blight': '''
   Cause: Bacterial infection (Pseudomonas savastanoi pv. glycinea).
   Symptoms: Watersoaked spots on leaves.
   Treatment: Use diseasefree seed, crop rotation.
   Prevention: Good sanitation, resistant varieties, avoid overhead irrigation.
''',
    'Soybean caterpillar': '''
   Cause: Insect infestation (various caterpillars).
   Symptoms: Leaf damage, defoliation.
   Treatment: Apply insecticides, biological control.
   Prevention: Monitor, handpicking, natural enemies.
''',
    'Soybean diabrotica speciosa': '''
   Cause: Insect infestation (Diabrotica speciosa).
   Symptoms: Leaf damage, root damage.
   Treatment: Apply insecticides, crop rotation.
   Prevention: Monitor, biological control, proper soil management.
''',
    'Soybean downy mildew': '''
   Cause: Oomycete infection (Peronospora manshurica).
   Symptoms: Yellow spots on leaves, white downy growth.
   Treatment: Apply metalaxyl fungicides, use resistant varieties.
   Prevention: Crop rotation, good drainage, resistant cultivars.
''',
    'Soybean healthy': 'Healthy soybean plant, no specific treatment needed.',
    'Soybean mosaic virus': '''
   Cause: Soybean mosaic virus (SMV).
   Symptoms: Mosaic pattern on leaves, stunted growth.
   Treatment: Remove infected plants, control vectors.
   Prevention: Use diseasefree seed, resistant varieties, vector control.
''',
    'Soybean powdery mildew': '''
   Cause: Fungal infection (Microsphaera diffusa).
   Symptoms: White powdery growth on leaves.
   Treatment: Apply sulfur or triazole fungicides.
   Prevention: Good air circulation, resistant varieties, proper spacing.
''',
    'Soybean rust': '''
   Cause: Fungal infection (Phakopsora pachyrhizi).
   Symptoms: Reddishbrown pustules on leaves.
   Treatment: Apply triazole or strobilurin fungicides.
   Prevention: Monitor, timely applications, resistant varieties.
''',
    'Soybean southern blight': '''
   Cause: Fungal infection (Sclerotium rolfsii).
   Symptoms: Wilting, white fungal growth at the base.
   Treatment: Crop rotation, deep tillage, apply fungicides.
   Prevention: Improve soil drainage, proper spacing, resistant varieties.
''',
    'Strawberry leaf scorch': '''
   Cause: Fungal infection (Diplocarpon earliana).
   Symptoms: Purple to brown spots on leaves.
   Treatment: Apply fungicides, remove infected leaves.
   Prevention: Good sanitation, proper spacing, resistant varieties.
''',
    'Strawberry healthy': 'Healthy strawberry plant, no specific treatment needed.',
    'Sugarcane bacterial blight': '''
   Cause: Bacterial infection (Xanthomonas albilineans).
   Symptoms: White streaks on leaves.
   Treatment: Use diseasefree seed, crop rotation.
   Prevention: Good sanitation, resistant varieties, proper drainage.
''',
    'Sugarcane healthy': 'Healthy sugarcane plant, no specific treatment needed.',
    'Sugarcane red rot': '''
   Cause: Fungal infection (Colletotrichum falcatum).
   Symptoms: Red discoloration inside the stalk.
   Treatment: Use resistant varieties, crop rotation.
   Prevention: Good sanitation, remove infected stalks, proper drainage.
''',
    'Sugarcane red stripe': '''
   Cause: Bacterial infection (Acidovorax avenae subsp. avenae).
   Symptoms: Red stripes on leaves.
   Treatment: Use diseasefree seed, crop rotation.
   Prevention: Good sanitation, resistant varieties, proper drainage.
''',
    'Sugarcane rust': '''
   Cause: Fungal infection (Puccinia melanocephala).
   Symptoms: Orange pustules on leaves.
   Treatment: Use resistant varieties, apply fungicides.
   Prevention: Monitor, timely applications, resistant cultivars.
''',
    'Tea algal leaf': '''
   Cause: Algal infection (Cephaleuros parasiticus).
   Symptoms: Orange to reddish spots on leaves.
   Treatment: Apply copper fungicides, improve drainage.
   Prevention: Prune for air circulation, proper shade management.
''',
    'Tea anthracnose': '''
   Cause: Fungal infection (Colletotrichum camelliae).
   Symptoms: Dark spots on leaves, dieback.
   Treatment: Apply copper fungicides, remove infected leaves.
   Prevention: Good sanitation, proper pruning, balanced fertilization.
''',
    'Tea bird eye spot': '''
   Cause: Fungal infection (Pestalotiopsis theae).
   Symptoms: Circular gray spots with dark borders on leaves.
   Treatment: Apply copper fungicides, remove infected leaves.
   Prevention: Good sanitation, proper pruning, balanced fertilization.
''',
    'Tea brown blight': '''
   Cause: Fungal infection (Glomerella cingulata).
   Symptoms: Brown spots on leaves, defoliation.
   Treatment: Apply copper fungicides, prune for air circulation.
   Prevention: Good sanitation, proper spacing, balanced fertilization.
''',
    'Tea healthy': 'Healthy tea plant, no specific treatment needed.',
    'Tea red leaf spot': '''
   Cause: Fungal infection (Cephaleuros parasiticus).
   Symptoms: Reddish spots on leaves.
   Treatment: Apply copper fungicides, remove infected leaves.
   Prevention: Good sanitation, proper pruning, balanced fertilization.
''',
    'Tomato bacterial spot': '''
   Cause: Bacterial infection (Xanthomonas vesicatoria).
   Symptoms: Watersoaked spots on leaves and fruit.
   Treatment: Apply copper fungicides, remove infected leaves.
   Prevention: Crop rotation, good sanitation, diseasefree seedlings.
''',
    'Tomato early blight': '''
   Cause: Fungal infection (Alternaria solani).
   Symptoms: Dark spots on leaves, targetlike lesions.
   Treatment: Apply chlorothalonil or mancozeb fungicides.
   Prevention: Crop rotation, good sanitation, resistant varieties.
''',
    'Tomato healthy': 'Healthy tomato plant, no specific treatment needed.',
    'Tomato late blight': '''
   Cause: Oomycete infection (Phytophthora infestans).
   Symptoms: Watersoaked lesions on leaves and fruit.
   Treatment: Apply mancozeb or chlorothalonil fungicides.
   Prevention: Good sanitation, resistant varieties, timely sprays.
''',
    'Tomato leaf mold': '''
   Cause: Fungal infection (Passalora fulva).
   Symptoms: Olivegreen to brown mold on lower leaf surfaces.
   Treatment: Improve air circulation, apply fungicides.
   Prevention: Greenhouse ventilation, proper spacing, resistant varieties.
''',
    'Tomato mosaic virus': '''
   Cause: Tomato mosaic virus (ToMV).
   Symptoms: Mosaic pattern on leaves, stunted growth.
   Treatment: Remove infected plants, control vectors.
   Prevention: Use resistant varieties, good sanitation, vector control.
''',
    'Tomato septoria leaf spot': '''
   Cause: Fungal infection (Septoria lycopersici).
   Symptoms: Circular gray spots with dark borders on leaves.
   Treatment: Apply chlorothalonil fungicides, remove infected leaves.
   Prevention: Crop rotation, good sanitation, proper spacing.
''',
    'Tomato spider mites (two spotted spider mite)': '''
   Cause: Mite infestation (Tetranychus urticae).
   Symptoms: Yellowing leaves, webbing.
   Treatment: Use miticides, insecticidal soap, neem oil.
   Prevention: Monitor, biological control, proper watering.
''',
    'Tomato target spot': '''
   Cause: Fungal infection (Corynespora cassiicola).
   Symptoms: Circular brown spots with concentric rings on leaves.
   Treatment: Apply chlorothalonil fungicides, remove infected leaves.
   Prevention: Crop rotation, good sanitation, proper spacing.
''',
    'Tomato yellow leaf curl virus': '''
   Cause: Tomato yellow leaf curl virus (TYLCV).
   Symptoms: Yellowing and curling of leaves, stunted growth.
   Treatment: Remove infected plants, control whiteflies.
   Prevention: Use resistant varieties, good sanitation, vector control.
''',
    'Wheat brown rust': '''
   Cause: Fungal infection (Puccinia triticina).
   Symptoms: Brown pustules on leaves.
   Treatment: Apply triazole fungicides, use resistant varieties.
   Prevention: Monitor, timely applications, resistant cultivars.
''',
    'Wheat healthy': 'Healthy wheat plant, no specific treatment needed.',
    'Wheat septoria': '''
   Cause: Fungal infection (Septoria tritici, Parastagonospora nodorum).
   Symptoms: Brown spots on leaves, lesions on glumes.
   Treatment: Apply triazole fungicides, crop rotation.
   Prevention: Good sanitation, resistant varieties, proper spacing.
''',
    'Wheat yellow rust': '''
   Cause: Fungal infection (Puccinia striiformis).
   Symptoms: Yellow pustules arranged in stripes on leaves.
   Treatment: Apply triazole fungicides, use resistant varieties.
   Prevention: Monitor, timely applications, resistant cultivars.
''',


  };

  List<List<List<List<double>>>> preprocessimage(File imageFile){
    img.Image? loadimage = img.decodeImage(imageFile.readAsBytesSync());
    img.Image resizedImage = img.copyResize(loadimage!, width: 256, height: 256);

    // Normalize pixel values to [0,1] and convert to tensor format
    List<List<List<List<double>>>> input = List.generate(
      1,
          (i) => List.generate(
        256,
            (y) => List.generate(
          256,
              (x) {
            img.Pixel pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0, // Red
              pixel.g / 255.0, // Green
              pixel.b / 255.0  // Blue
            ];
          },
        ),
      ),
    );

    return input;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  void _fetchUserDetails() {
    setState(() {
      user = FirebaseAuth.instance.currentUser; // Fetch currently logged-in user
    });
  }

  void _showUserDetails(BuildContext context) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("User Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user!.photoURL != null)
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user!.photoURL!),
                ),
              const SizedBox(height: 10),
              Text("Name: ${user!.displayName ?? 'N/A'}"),
              Text("Email: ${user!.email ?? 'N/A'}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> classifier() async{
    // loadModel();
    try{
      _interpreter = await Interpreter.fromAsset('lib/assets/tflite_model.tflite');
      print("model loaded");
      // return;
    }catch(e){
      print("model failed to load");
    }

    var input = preprocessimage(_selectedImage!);
    var output = List.generate(1, (_) => List.filled(88,0.0));

    _interpreter!.run(input, output);

    List<double> outputResult = output[0];

    double maxValue = outputResult.reduce((a,b) => a>b?a:b);
    int maxIndex = outputResult.indexOf(maxValue);

    String predictedClass = _classnames[maxIndex];
    String solution = plantDiseaseSolutions[predictedClass] ?? "No solution available.";

    setState(() {
      _result = {"class":_classnames[maxIndex],"confidence":maxValue};
      Solution = solution;
    });

    print("🔹 Model Output: $_result");
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _cancelImage() {
    setState(() {
      _selectedImage = null;
      _result = null;
    });
  }


  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Ensure LoginScreen exists
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-out failed: ${e.toString()}")),
      );
    }
  }
  void _resetImage() {
    setState(() {
      _selectedImage = null;
      _result = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'lib/assets/logo.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 10),
                const Text(
                  'DR.CROP',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            )]),
          actions: [

            // User Icon (Clickable to Show Details)
            IconButton(
              icon: CircleAvatar(
                backgroundImage: user!.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : const AssetImage("lib/assets/default_avatar.png") as ImageProvider,
              ),
              onPressed: () => _showUserDetails(context),
            ),

            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () {
                _signOut(context); // Call the sign-out function directly
              },
            )
          ],
        ),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Heal your crop !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'lib/assets/process.png',
                      width: 250,
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: const [
                        Text('Take a picture',style: TextStyle(fontWeight: FontWeight.bold)),
                        Icon(Icons.arrow_forward, color: Colors.black87),
                        Text('Analysing',style: TextStyle(fontWeight: FontWeight.bold)),
                        Icon(Icons.arrow_forward, color: Colors.black87),
                        Text('Get Solution',style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 20),
                Image.file(
                  _selectedImage!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),


                if (_result != null) ...[
                  Column(
                    children: [
                      Container(
                        height: 43,
                        width: 250,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
                        ),
                        child: Text(
                          "Disease: ${_result!["class"]}",
                          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Container(
                      //   width: 300,
                      //   padding: EdgeInsets.all(15),
                      //   decoration: BoxDecoration(
                      //     color: Colors.lightGreen[100],
                      //     borderRadius: BorderRadius.circular(10),
                      //   ),
                      //   child: Text(
                      //     "Solution:\n$Solution",
                      //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                      //   ),
                      // ),

                      Container(
                        width: 360, // Slightly wider for better spacing
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white, // Clean and modern background
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26, // Subtle shadow for a professional look
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.green.shade400, width: 2), // Adds a nice border
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Solution:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700, // Slightly darker green for contrast
                              ),
                            ),
                            const SizedBox(height: 8), // Adds spacing between the title and content
                            Text(
                              Solution!,
                              style: const TextStyle(
                                fontSize: 10,
                                // fontFamily: 'Times New Roman',
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                height: 1.5, // Improves readability
                              ),
                            ),
                          ],
                        ),
                      ),


                      const SizedBox(height: 10),

                      // Reset Button (Only visible after diagnosis)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _resetImage,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.black, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 30),
                            ),
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: const Text(
                              'Reset',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,

                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: classifier,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                          side: const BorderSide(color: Colors.black, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        icon: const Icon(Icons.medical_services, color: Colors.white),
                        label: const Text(
                          'Diagnose',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _cancelImage,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red,
                          side: const BorderSide(color: Colors.black, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]] else ...[
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.upload, color: Colors.white),
                        label: const Text(
                          'Upload an Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.black, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text(
                          'Take a picture',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.black, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
