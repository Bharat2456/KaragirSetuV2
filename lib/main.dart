import 'package:flutter/material.dart';

void main()=>runApp(const KaragirSetuApp());
const olive=Color(0xFF70823E), sand=Color(0xFFDFC799), gold=Color(0xFFE0B44A), terra=Color(0xFFD8853F), ivory=Color(0xFFF3EDE0), earth=Color(0xFF866C5A), ink=Color(0xFF342D27);

class KaragirSetuApp extends StatelessWidget {
 const KaragirSetuApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(title:'KaragirSetu V2',debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:olive),scaffoldBackgroundColor:ivory),home:const LoginPage());
}
class LoginPage extends StatefulWidget {const LoginPage({super.key});@override State<LoginPage> createState()=>_LoginPageState();}
class _LoginPageState extends State<LoginPage>{
 final u=TextEditingController(text:'BharatPotery@login'),p=TextEditingController(text:'Bharat2456');String? error;
 @override Widget build(BuildContext context)=>Scaffold(body:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:440),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 const Icon(Icons.spa_rounded,size:72,color:olive),const Text('KaragirSetu',textAlign:TextAlign.center,style:TextStyle(fontSize:32,fontWeight:FontWeight.bold,color:ink)),const Text('Your craft. Your story. Your marketplace.',textAlign:TextAlign.center),
 const SizedBox(height:24),TextField(controller:u,decoration:const InputDecoration(labelText:'Username')),const SizedBox(height:12),TextField(controller:p,obscureText:true,decoration:const InputDecoration(labelText:'Password')),
 if(error!=null)Text(error!,style:const TextStyle(color:Colors.red)),const SizedBox(height:16),
 FilledButton(onPressed:(){if(u.text.trim()=='BharatPotery@login'&&p.text=='Bharat2456'){Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const HomePage()));}else{setState(()=>error='Incorrect demo credentials');}},child:const Text('Sign in')),
 const SizedBox(height:16),const Text('Demo: BharatPotery@login  /  Bharat2456',textAlign:TextAlign.center,style:TextStyle(color:earth))
 ])))));
}
class HomePage extends StatefulWidget {const HomePage({super.key});@override State<HomePage> createState()=>_HomePageState();}
class _HomePageState extends State<HomePage>{
 int tab=0;final names=['Dashboard','Analytics','Products','Orders','Marketplace','Settings'];
 final products=<String>['Hand-thrown Terracotta Vase','Indigo Block-print Stole','Hand-carved Wooden Bird'];
 final markets=<String,bool>{'GeM':true,'ONDC':false,'Amazon Karigar':false,'Flipkart Samarth':false};
 @override Widget build(BuildContext context){
 final content=<Widget>[
 _page('Namaste, Bharat','A quick view of your artisan business.',[ _metric('₹28,460','Revenue · 30 days'),_metric('18','Orders · 30 days'),_metric('${products.length}','Products') ]),
 _page('Analytics','Illustrative sample data · not live transactions.',[_metric('₹28,460','30-day sales'),_metric('₹3,42,800','1-year sales'),const Text('Top product: Terracotta Vase\\nMarketplace profit figures are sample estimates.')]),
 _page('Products','Your saved craft catalog.',[FilledButton.icon(onPressed:()=>_newProduct(),icon:const Icon(Icons.add),label:const Text('Add product')),...products.map((x)=>Card(child:ListTile(title:Text(x),subtitle:const Text('Sample listing · tap to preview'),onTap:()=>showDialog(context:context,builder:(_)=>AlertDialog(title:Text(x),content:const Text('Buyer-facing preview. Add full product creation and AI provider integration in a subsequent build.'),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Close'))]))))]),
 _page('Orders','Preparation and payment status.',[for(final o in ['ORD-2408 · Vase · 2 units · Due Sep 24 · Paid','ORD-2407 · Stole · 1 unit · Due Sep 25 · Paid','ORD-2406 · Bird · 3 units · Due Sep 22 · Payment pending'])Card(child:ListTile(title:Text(o),subtitle:const Text('Demo order')))]),
 _page('Marketplace','Prototype switches only; no live marketplace publishing.',[...markets.entries.map((e)=>SwitchListTile(title:Text(e.key),subtitle:Text(e.value?'Enabled':'Disabled'),value:e.value,onChanged:(v)=>setState(()=>markets[e.key]=v)))]),
 _page('Settings','Demo profile and configuration.',[const ListTile(title:Text('Bharat Wagh'),subtitle:Text('Bharat Pottery · Pune, Maharashtra')),const Text('AI keys and real authentication are not connected in this syntax-repair build.'),FilledButton(onPressed:()=>Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const LoginPage()),(_)=>false),child:const Text('Log out'))])
 ];
 return Scaffold(appBar:AppBar(title:Text(names[tab])),body:content[tab],bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const[NavigationDestination(icon:Icon(Icons.dashboard),label:'Home'),NavigationDestination(icon:Icon(Icons.query_stats),label:'Analytics'),NavigationDestination(icon:Icon(Icons.inventory_2),label:'Products'),NavigationDestination(icon:Icon(Icons.receipt_long),label:'Orders'),NavigationDestination(icon:Icon(Icons.storefront),label:'Markets'),NavigationDestination(icon:Icon(Icons.settings),label:'Settings')]));
 }
 Widget _page(String title,String subtitle,List<Widget> children)=>ListView(padding:const EdgeInsets.all(16),children:[Text(title,style:const TextStyle(fontSize:26,fontWeight:FontWeight.bold,color:ink)),Text(subtitle,style:const TextStyle(color:earth)),const SizedBox(height:16),...children]);
 Widget _metric(String value,String label)=>Card(child:ListTile(leading:const Icon(Icons.insights,color:olive),title:Text(value,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),subtitle:Text(label)));
 void _newProduct(){final c=TextEditingController();showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('Add a product'),content:TextField(controller:c,decoration:const InputDecoration(labelText:'Product name')),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:(){if(c.text.trim().isNotEmpty)setState(()=>products.add(c.text.trim()));Navigator.pop(context);},child:const Text('Save'))]));}
}
