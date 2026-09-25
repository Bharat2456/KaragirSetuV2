import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/localization_service.dart';
import 'services/groq_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const KaragirSetuApp()); }

const olive = Color(0xFF70823E), sand = Color(0xFFDFC799), gold = Color(0xFFE0B44A), terracotta = Color(0xFFD8853F), ivory = Color(0xFFF3EDE0), earth = Color(0xFF866C5A), ink = Color(0xFF342D27);

class KaragirSetuApp extends StatelessWidget {
  const KaragirSetuApp({super.key});
  @override Widget build(BuildContext context) => ValueListenableBuilder<String>(valueListenable: AppLocale.notifier, builder: (_, __, ___) => MaterialApp(title:'KaragirSetu V2', debugShowCheckedModeBanner:false, theme:ThemeData(useMaterial3:true, scaffoldBackgroundColor:ivory, colorScheme:ColorScheme.fromSeed(seedColor:olive, primary:olive, secondary:terracotta, surface:Colors.white), appBarTheme:const AppBarTheme(backgroundColor:ivory, foregroundColor:ink, elevation:0), inputDecorationTheme:InputDecorationTheme(filled:true, fillColor:ivory.withOpacity(.55), border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none), contentPadding:const EdgeInsets.all(15))), home:const LoginScreen(), builder:(context, child) => Directionality(textDirection: AppLocale.isRtl ? TextDirection.rtl : TextDirection.ltr, child: child!)));
}

class DemoData {
 static final products=<CraftProduct>[
  CraftProduct(id:'KS-101',name:'Hand-thrown Terracotta Vase',category:'Pottery',price:1299,stock:24,description:'A warm, earthy vase shaped and finished by hand.',story:'Inspired by the quiet beauty of everyday Indian homes. Each piece carries the subtle marks of the maker.',materials:'Natural terracotta clay',leadDays:5),
  CraftProduct(id:'KS-102',name:'Indigo Block-print Stole',category:'Textile',price:1890,stock:16,description:'A lightweight cotton stole with a traditional indigo print.',story:'Printed by hand using a repeating carved-block motif.',materials:'Cotton, natural indigo dye',leadDays:7),
  CraftProduct(id:'KS-103',name:'Hand-carved Wooden Bird',category:'Woodcraft',price:850,stock:9,description:'A small decorative bird carved from wood.',story:'A cheerful piece for a shelf, desk, or thoughtful gift.',materials:'Seasoned wood',leadDays:4),
 ];
 static final orders=<CraftOrder>[
  CraftOrder(id:'ORD-2408',product:'Hand-thrown Terracotta Vase',buyer:'Aarav Mehta',qty:2,total:2598,status:'New',paid:true,due:'Sep 24'),
  CraftOrder(id:'ORD-2407',product:'Indigo Block-print Stole',buyer:'Nisha Shah',qty:1,total:1890,status:'In progress',paid:true,due:'Sep 25'),
  CraftOrder(id:'ORD-2406',product:'Hand-carved Wooden Bird',buyer:'Rohan Kulkarni',qty:3,total:2550,status:'Ready',paid:false,due:'Sep 22'),
  CraftOrder(id:'ORD-2405',product:'Hand-thrown Terracotta Vase',buyer:'Mira Joshi',qty:1,total:1299,status:'Delivered',paid:true,due:'Sep 18'),
 ];
 static final marketplaces=<MarketLink>[
  MarketLink('Government e-Marketplace (GeM)','Public procurement marketplace',true,true),MarketLink('ONDC','Open network for digital commerce',true,false),MarketLink('Amazon Karigar','Handmade seller program',false,false),MarketLink('Flipkart Samarth','Seller enablement program',false,false),MarketLink('State artisan portal','Regional craft marketplace',false,false),
 ];
}
class CraftProduct { String id,name,category,description,story,materials; double price; int stock,leadDays; List<String> photos; CraftProduct({required this.id,required this.name,required this.category,required this.price,required this.stock,required this.description,required this.story,required this.materials,required this.leadDays,this.photos=const[]}); }
class CraftOrder {String id,product,buyer,status,due;int qty;double total;bool paid;CraftOrder({required this.id,required this.product,required this.buyer,required this.qty,required this.total,required this.status,required this.paid,required this.due});}
class MarketLink {String name,subtitle;bool connected,enabled;MarketLink(this.name,this.subtitle,this.connected,this.enabled);}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final user = TextEditingController(text:'BharatPotery@login');
  final pass = TextEditingController(text:'Bharat2456');
  bool obscure = true;
  String? error;

  void login() {
    if (user.text.trim() == 'BharatPotery@login' && pass.text == 'Bharat2456') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppShell()));
    } else {
      setState(() => error = 'Check the demo username and password.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(height:82,width:82,decoration:BoxDecoration(color:olive,borderRadius:BorderRadius.circular(26)),child:const Icon(Icons.spa_rounded,color:ivory,size:45)),
        const SizedBox(height:24), const LText('KaragirSetu',style:TextStyle(fontSize:34,fontWeight:FontWeight.w900,color:ink)),
        const LText('Your craft. Your story. Your marketplace.',style:TextStyle(color:earth,fontSize:15)),
        const SizedBox(height:32), const LText('Welcome back',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold)),
        const SizedBox(height:6), const LText('Sign in to your artisan workspace.',style:TextStyle(color:earth)),
        const SizedBox(height:22),
        Column(crossAxisAlignment:CrossAxisAlignment.start,children:[InputDecorator(decoration:InputDecoration(labelText:L10n.t('Language')),child:DropdownButtonHideUnderline(child:DropdownButton<String>(value:AppLocale.code,isExpanded:true,items:AppLanguages.supported.map((l)=>DropdownMenuItem<String>(value:l.code,enabled:l.code=='en'||l.mlKit!=null,child:Row(children:[Expanded(child:Text(l.nativeName)),if(l.code!='en'&&l.mlKit==null)const LText(' • pack needed',style:TextStyle(fontSize:11,color:earth))]))).toList(),onChanged:(v) async {if(v!=null){await L10n.warmLanguage(v);AppLocale.set(v);setState((){});}}))),const SizedBox(height:6),const LText('Full on-device UI translation is available for 10 Indian languages in this build. The other scheduled languages remain listed for future Indic translation packs.',style:TextStyle(fontSize:11,color:earth))]),
        const SizedBox(height:12),
        TextField(controller:user,decoration:InputDecoration(labelText:L10n.t('Username'))),const SizedBox(height:12),
        TextField(controller:pass,obscureText:obscure,decoration:InputDecoration(labelText:L10n.t('Password'),suffixIcon:IconButton(icon:Icon(obscure?Icons.visibility_outlined:Icons.visibility_off_outlined),onPressed:()=>setState(()=>obscure=!obscure)))),
        if(error!=null) Padding(padding:const EdgeInsets.only(top:8),child:LText(error!,style:const TextStyle(color:Colors.red))),
        const SizedBox(height:20), FilledButton(onPressed:login,style:FilledButton.styleFrom(padding:const EdgeInsets.all(17),backgroundColor:olive),child:const LText('Sign in',style:TextStyle(fontSize:16,fontWeight:FontWeight.bold))),
        const SizedBox(height:18), Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:sand.withOpacity(.35),borderRadius:BorderRadius.circular(16)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LText('DEMO ACCESS',style:TextStyle(fontWeight:FontWeight.bold,color:earth,fontSize:12)),SizedBox(height:8),SelectableText('BharatPotery@login'),SelectableText('Bharat2456'),SizedBox(height:6),LText('Prototype account only. Replace demo authentication before real deployment.',style:TextStyle(fontSize:12,color:earth))])),
        const SizedBox(height:22), const Center(child:LText('Made for the people behind the craft ✦',style:TextStyle(color:earth)))
      ]),
    )))),
  );
}

class AppShell extends StatefulWidget {const AppShell({super.key});@override State<AppShell> createState()=>_AppShellState();}
class _AppShellState extends State<AppShell>{int tab=0;final titles=['Dashboard','Analytics','Products','Orders','Marketplace','Settings'];void refresh()=>setState((){});@override Widget build(BuildContext context){final pages=[DashboardPage(onNavigate:(i)=>setState(()=>tab=i)),AnalyticsPage(),ProductsPage(onChanged:refresh),OrdersPage(),MarketplacePage(onChanged:refresh),SettingsPage()];return Scaffold(appBar:AppBar(title:Row(children:[Container(width:34,height:34,decoration:BoxDecoration(color:olive,borderRadius:BorderRadius.circular(11)),child:const Icon(Icons.spa,color:ivory,size:21)),const SizedBox(width:10),LText(titles[tab],style:const TextStyle(fontWeight:FontWeight.w800))]),actions:[IconButton(onPressed:()=>setState(()=>tab=5),icon:const CircleAvatar(backgroundColor:sand,child:LText('B',style:TextStyle(color:ink,fontWeight:FontWeight.bold))))],),body:IndexedStack(index:tab,children:pages),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),backgroundColor:Colors.white,indicatorColor:sand.withOpacity(.65),labelBehavior:NavigationDestinationLabelBehavior.onlyShowSelected, destinations:[NavigationDestination(icon:const Icon(Icons.dashboard_outlined),selectedIcon:const Icon(Icons.dashboard),label:L10n.t('Home')),NavigationDestination(icon:const Icon(Icons.query_stats),label:L10n.t('Analytics')),NavigationDestination(icon:const Icon(Icons.inventory_2_outlined),label:L10n.t('Products')),NavigationDestination(icon:const Icon(Icons.receipt_long_outlined),label:L10n.t('Orders')),NavigationDestination(icon:const Icon(Icons.storefront_outlined),label:L10n.t('Markets')),NavigationDestination(icon:const Icon(Icons.settings_outlined),label:L10n.t('Settings'))]));}}

class PageBody extends StatelessWidget{final Widget child;const PageBody({super.key,required this.child});@override Widget build(BuildContext context)=>SingleChildScrollView(padding:const EdgeInsets.fromLTRB(16,6,16,28),child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:720),child:child)));}
Widget heading(String title,String subtitle)=>Padding(padding:const EdgeInsets.only(bottom:18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LText(title,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:ink)),const SizedBox(height:4),LText(subtitle,style:const TextStyle(color:earth,fontSize:13))]));
Widget panel({required Widget child,EdgeInsets padding=const EdgeInsets.all(16)})=>Container(width:double.infinity,padding:padding,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20),border:Border.all(color:earth.withOpacity(.10))),child:child);
Widget sectionTitle(String s,{Widget? trailing})=>Padding(padding:const EdgeInsets.only(bottom:12),child:Row(children:[Expanded(child:LText(s,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800,color:ink))),if(trailing!=null)trailing]));

class DashboardPage extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const DashboardPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final orders = DemoData.orders.where((o) => o.status != 'Delivered').length;
    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [olive, Color(0xFF89975D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LText('NAMASTE, BHARAT 👋', style: TextStyle(color: ivory, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
                const SizedBox(height: 8),
                const LText('Your craft is going places.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 25)),
                const SizedBox(height: 8),
                const LText('Here’s what’s happening in your artisan business.', style: TextStyle(color: ivory)),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => onNavigate(2),
                  icon: const Icon(Icons.add),
                  label: const LText('Create a product'),
                  style: FilledButton.styleFrom(backgroundColor: ivory, foregroundColor: olive),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              _metric('₹ 28,460', 'Revenue · 30 days', Icons.currency_rupee, olive),
              _metric('18', 'Orders · 30 days', Icons.shopping_bag_outlined, terracotta),
              _metric('12', 'Active products', Icons.inventory_2_outlined, gold),
              _metric('$orders', 'Orders to prepare', Icons.local_shipping_outlined, earth),
            ],
          ),
          const SizedBox(height: 22),
          sectionTitle('Sales at a glance', trailing: TextButton(onPressed: () => onNavigate(1), child: const LText('View analytics'))),
          panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  LText('₹28,460', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
                  SizedBox(width: 8),
                  Chip(label: LText('+12.8%', style: TextStyle(color: olive, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFEAF0DD)),
                ]),
                const LText('Compared with previous 30 days · demo data', style: TextStyle(color: earth, fontSize: 12)),
                const SizedBox(height: 18),
                const SizedBox(height: 100, child: CustomPaint(painter: MiniChartPainter(), child: SizedBox.expand())),
              ],
            ),
          ),
          const SizedBox(height: 22),
          sectionTitle('Needs your attention', trailing: TextButton(onPressed: () => onNavigate(3), child: const LText('All orders'))),
          ...DemoData.orders.where((o) => o.status != 'Delivered').take(3).map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: panel(
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(color: sand.withOpacity(.35), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.inventory_2_outlined, color: earth),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LText(o.product, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          LText('${o.id} · ${o.qty} unit(s) · Due ${o.due}', style: const TextStyle(color: earth, fontSize: 12)),
                        ],
                      ),
                    ),
                    _status(o.status),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
Widget _metric(String value,String label,IconData icon,Color color)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:earth.withOpacity(.1))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Icon(icon,color:color),LText(value,style:const TextStyle(fontSize:23,fontWeight:FontWeight.w900,color:ink)),LText(label,style:const TextStyle(fontSize:11,color:earth))]));
Widget _status(String s)=>Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),decoration:BoxDecoration(color:(s=='Ready'?olive:s=='New'?terracotta:gold).withOpacity(.14),borderRadius:BorderRadius.circular(20)),child:LText(s,style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:s=='Ready'?olive:s=='New'?terracotta:earth)));
class MiniChartPainter extends CustomPainter{const MiniChartPainter();@override void paint(Canvas c,Size s){final p=Paint()..color=olive..strokeWidth=3..style=PaintingStyle.stroke..strokeCap=StrokeCap.round;final path=Path()..moveTo(0,s.height*.78)..cubicTo(s.width*.12,s.height*.65,s.width*.15,s.height*.2,s.width*.28,s.height*.48)..cubicTo(s.width*.4,s.height*.8,s.width*.52,s.height*.12,s.width*.62,s.height*.35)..cubicTo(s.width*.76,s.height*.62,s.width*.83,s.height*.25,s.width,s.height*.12);c.drawPath(path,p);final fill=Paint()..shader=LinearGradient(colors:[olive.withOpacity(.18),olive.withOpacity(0)],begin:Alignment.topCenter,end:Alignment.bottomCenter).createShader(Offset.zero& s);final area=Path.from(path)..lineTo(s.width,s.height)..lineTo(0,s.height)..close();c.drawPath(area,fill);}@override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;}

class AnalyticsPage extends StatefulWidget{const AnalyticsPage({super.key});@override State<AnalyticsPage> createState()=>_AnalyticsPageState();}
class _AnalyticsPageState extends State<AnalyticsPage>{String range='30 days';@override Widget build(BuildContext context){final annual=range=='1 year';return PageBody(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[heading('Your business, at a glance','Understand what sells, where it sells, and what you earn.'),SegmentedButton<String>(segments:const[ButtonSegment(value:'30 days',label:LText('30 days')),ButtonSegment(value:'1 year',label:LText('1 year'))],selected:{range},onSelectionChanged:(s)=>setState(()=>range=s.first)),const SizedBox(height:16),GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.5,children:[_metric(annual?'₹3.42L':'₹28,460','Gross sales',Icons.currency_rupee,olive),_metric(annual?'₹1.28L':'₹10,920','Estimated profit',Icons.savings_outlined,terracotta),_metric(annual?'214':'18','Orders',Icons.shopping_bag_outlined,gold),_metric(annual?'₹1,598':'₹1,581','Average order',Icons.receipt_long,earth)]),const SizedBox(height:20),sectionTitle('Sales trend'),panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LText(annual?'Monthly sales · sample':'Daily/weekly sales · sample',style:const TextStyle(color:earth,fontSize:12)),const SizedBox(height:15),SizedBox(height:170,child:CustomPaint(painter:BarChartPainter(annual?const[.3,.48,.4,.62,.52,.7,.58,.83,.68,.92,.75,1]:const[.38,.55,.44,.78,.58,.68,.95]),child:const SizedBox.expand()))])),const SizedBox(height:20),sectionTitle('Product performance'),...['Hand-thrown Terracotta Vase','Indigo Block-print Stole','Hand-carved Wooden Bird'].asMap().entries.map((e){final vals=annual?['84 sold · ₹1.09L','62 sold · ₹1.17L','41 sold · ₹34.8K']:['8 sold · ₹10.4K','6 sold · ₹11.3K','4 sold · ₹3.4K'];return Padding(padding:const EdgeInsets.only(bottom:9),child:panel(padding:const EdgeInsets.all(14),child:Row(children:[CircleAvatar(backgroundColor:[sand,gold,ivory][e.key],child:Icon(Icons.category,color:earth)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LText(e.value,style:const TextStyle(fontWeight:FontWeight.bold)),LText(vals[e.key],style:const TextStyle(color:earth,fontSize:12))])),LText('#${e.key+1}',style:const TextStyle(color:earth,fontWeight:FontWeight.bold))])));}),const SizedBox(height:12),sectionTitle('Marketplace comparison'),panel(child:Column(children:[_marketStat('GeM','9 orders','₹14,200',.82),const Divider(),_marketStat('ONDC','5 orders','₹8,450',.58),const Divider(),_marketStat('Direct share link','4 orders','₹5,810',.42),const SizedBox(height:8),const LText('Illustrative demo figures. Profit estimates exclude platform-specific fee verification.',style:TextStyle(fontSize:11,color:earth))]))]));}}
Widget _marketStat(String name,String orders,String profit,double progress)=>Row(children:[Expanded(flex:3,child:LText(name,style:const TextStyle(fontWeight:FontWeight.bold))),Expanded(flex:4,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LText(orders,style:const TextStyle(fontSize:12,color:earth)),const SizedBox(height:5),LinearProgressIndicator(value:progress,color:olive,backgroundColor:ivory,minHeight:6,borderRadius:BorderRadius.circular(5))])),const SizedBox(width:10),LText(profit,style:const TextStyle(fontWeight:FontWeight.bold))]);
class BarChartPainter extends CustomPainter{final List<double> values;BarChartPainter(this.values);@override void paint(Canvas c,Size s){final w=s.width/values.length;for(var i=0;i<values.length;i++){final h=s.height*values[i]*.88;final r=RRect.fromRectAndRadius(Rect.fromLTWH(i*w+w*.16,s.height-h,w*.68,h),const Radius.circular(5));c.drawRRect(r,Paint()..color=i==values.length-1?terracotta:olive.withOpacity(.72));}}@override bool shouldRepaint(covariant BarChartPainter old)=>old.values!=values;}

class ProductsPage extends StatefulWidget{final VoidCallback onChanged;const ProductsPage({super.key,required this.onChanged});@override State<ProductsPage> createState()=>_ProductsPageState();}
class _ProductsPageState extends State<ProductsPage>{String query='';@override Widget build(BuildContext context){final list=DemoData.products.where((p)=>p.name.toLowerCase().contains(query.toLowerCase())).toList();return PageBody(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[heading('Your products','Your craft catalog, ready to improve and share.'),FilledButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>CreateProductPage(onSaved:widget.onChanged))),icon:const Icon(Icons.add),label:const LText('Create product listing'),style:FilledButton.styleFrom(minimumSize:const Size.fromHeight(52),backgroundColor:olive)),const SizedBox(height:16),TextField(onChanged:(v)=>setState(()=>query=v),decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:L10n.t('Search your products'))),const SizedBox(height:14),Row(children:[LText('${list.length} listings',style:const TextStyle(color:earth,fontWeight:FontWeight.bold)),const Spacer(),const LText('Demo catalog',style:TextStyle(color:earth,fontSize:12))]),const SizedBox(height:10),...list.map((p)=>Padding(padding:const EdgeInsets.only(bottom:12),child:panel(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Container(width:68,height:68,decoration:BoxDecoration(color:sand.withOpacity(.35),borderRadius:BorderRadius.circular(14)),child:p.photos.isNotEmpty?ClipRRect(borderRadius:BorderRadius.circular(14),child:Image.file(File(p.photos.first),fit:BoxFit.cover)):const Icon(Icons.local_mall_outlined,color:earth,size:30)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LText(p.name,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:15)),LText('${p.category} · ${p.stock} available',style:const TextStyle(color:earth,fontSize:12)),const SizedBox(height:4),LText('₹${p.price.toStringAsFixed(0)}',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:18,color:olive))])),PopupMenuButton<String>(onSelected:(v){if(v=='preview')Navigator.push(context,MaterialPageRoute(builder:(_)=>ListingPreviewPage(product:p)));if(v=='share')showShareDialog(context,p);if(v=='publish')showPublishDialog(context,p);},itemBuilder:(_)=>const[PopupMenuItem(value:'preview',child:LText('Preview listing')),PopupMenuItem(value:'share',child:LText('Share product page')),PopupMenuItem(value:'publish',child:LText('Publish (demo)'))])]),const Divider(height:22),Row(children:[const Icon(Icons.auto_awesome,color:terracotta,size:17),const SizedBox(width:6),const Expanded(child:LText('AI-crafted listing',style:TextStyle(color:earth,fontSize:12))),TextButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ListingPreviewPage(product:p))),child:const LText('View page'))])]))))]));}}
void showShareDialog(BuildContext context,CraftProduct p)=>showDialog(context:context,builder:(_)=>AlertDialog(title:const LText('Share product page'),content:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[const LText('KaragirSetu demo listing'),LText(p.name),LText('₹${p.price.toStringAsFixed(0)}'),const SizedBox(height:8),LText(p.description),const SizedBox(height:8),const LText('A shareable public URL will be available when hosted publishing is connected.')]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const LText('Close'))]));
void showPublishDialog(BuildContext context,CraftProduct p)=>showDialog(context:context,builder:(_)=>AlertDialog(title:const LText('Demo publish'),content:LText('“${p.name}” is ready for a simulated publish action. Live marketplace publishing needs verified seller accounts and approved platform integrations.'),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const LText('Cancel')),FilledButton(onPressed:(){Navigator.pop(context);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:LText('Demo publish recorded locally. No external marketplace was contacted.')));},child:const LText('Simulate publish'))]));

class CreateProductPage extends StatefulWidget {
  final VoidCallback onSaved;
  const CreateProductPage({super.key, required this.onSaved});
  @override State<CreateProductPage> createState()=>_CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final name=TextEditingController(), category=TextEditingController(text:'Handicraft'), details=TextEditingController(), materials=TextEditingController(), price=TextEditingController(), capacity=TextEditingController(text:'100'), days=TextEditingController(text:'10');
  final picker=ImagePicker(); final photos=<XFile>[]; final speech=stt.SpeechToText();
  bool busy=false, listening=false, speechReady=false; String? aiText; String inputLanguage='en-US'; List<stt.LocaleName> locales=[];

  @override void initState(){super.initState(); _initSpeech();}
  Future<void> _initSpeech() async { speechReady=await speech.initialize(onStatus:(s){if((s=='done'||s=='notListening')&&mounted)setState(()=>listening=false);},onError:(_){if(mounted)setState(()=>listening=false);}); if(speechReady) locales=await speech.locales(); if(mounted)setState((){}); }
  Future<void> pick(ImageSource source)async{final f=source==ImageSource.gallery?await picker.pickMultiImage():[if(await picker.pickImage(source:source) case final XFile x)x];if(f.isNotEmpty)setState(()=>photos.addAll(f));}
  Future<void> speak(){return _toggleSpeech();}
  Future<void> _toggleSpeech() async {
    if(!speechReady)return;
    if(listening){await speech.stop();if(mounted)setState(()=>listening=false);return;}
    setState(()=>listening=true);
    await speech.listen(localeId:inputLanguage,onResult:(r){if(mounted)setState(()=>details.text=r.recognizedWords);});
  }
  Future<void> generate() async {
    if(details.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:LText('Add a few details about your craft first.')));return;}
    final key=await _getApiKey('Groq');
    if(key.isEmpty){setState(()=>aiText='Add your Groq API key in Settings to enable live generation. You can still save a manually drafted listing.');return;}
    setState(()=>busy=true);
    try {
      final result=await GroqService.generateTextListing(apiKey:key,productName:name.text,category:category.text,details:details.text,materials:materials.text,price:price.text,capacity:capacity.text,days:days.text,outputLanguage:AppLocale.current.name);
      if(mounted)setState(()=>aiText=result);
    } catch(e){if(mounted)setState(()=>aiText='AI request failed: $e\n\nCheck your Groq key, internet connection, quota and model availability.');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  @override void dispose(){name.dispose();category.dispose();details.dispose();materials.dispose();price.dispose();capacity.dispose();days.dispose();speech.stop();super.dispose();}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LText('Create product')),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading('Let’s tell its story', 'Add what you know. AI helps shape the buyer-facing page.'),
            panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                sectionTitle('1 · Product photos & video'),
                const LText('Add multiple photos. Video selection is not enabled in this prototype.', style: TextStyle(color: earth, fontSize: 12)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(onPressed: () => pick(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: const LText('Take photo')),
                    OutlinedButton.icon(onPressed: () => pick(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const LText('Upload photos')),
                  ],
                ),
                if (photos.isNotEmpty)
                  SizedBox(
                    height: 105,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: photos.map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(f.path), width: 105, height: 105, fit: BoxFit.cover)),
                      )).toList(),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 12),
            panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                sectionTitle('2 · Craft details'),
                TextField(controller: name, decoration: InputDecoration(labelText: L10n.t('Product name (optional)'))),
                const SizedBox(height: 10),
                TextField(controller: category, decoration: InputDecoration(labelText: L10n.t('Category'))),
                const SizedBox(height: 10),
                TextField(
                  controller: details,
                  maxLines: 5,
                  decoration: InputDecoration(labelText: L10n.t('Tell us about the product'), hintText: L10n.t('What is it? How is it made? What makes it special?')),
                ),
                const SizedBox(height: 10),
                if (speechReady)
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: L10n.t('Voice input language')),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: locales.any((l) => l.localeId == inputLanguage) ? inputLanguage : (locales.isNotEmpty ? locales.first.localeId : null),
                              isExpanded: true,
                              items: locales.map((l) => DropdownMenuItem(value: l.localeId, child: Text(l.name))).toList(),
                              onChanged: (v) { if (v != null) setState(() => inputLanguage = v); },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(onPressed: speak, icon: Icon(listening ? Icons.stop : Icons.mic), tooltip: L10n.t('Speak')),
                    ],
                  ),
                const SizedBox(height: 10),
                TextField(controller: materials, decoration: InputDecoration(labelText: L10n.t('Materials (if known)'))),
              ]),
            ),
            const SizedBox(height: 12),
            panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                sectionTitle('3 · Price & production'),
                TextField(controller: price, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: L10n.t('Your selling price (₹)'))),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextField(controller: capacity, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: L10n.t('Units you can make')))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: days, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: L10n.t('In how many days?')))),
                ]),
                const SizedBox(height: 8),
                const LText('The app will show the stated production time; shipping estimates must come from the marketplace.', style: TextStyle(fontSize: 12, color: earth)),
              ]),
            ),
            const SizedBox(height: 12),
            panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                sectionTitle('4 · AI listing studio'),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: ivory, borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome, color: terracotta),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const LText('Groq AI', style: TextStyle(fontWeight: FontWeight.bold)),
                      LText('Generates the listing in your selected UI language.', style: const TextStyle(color: earth, fontSize: 12)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: busy ? null : generate,
                  icon: busy ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
                  label: LText(busy ? 'Generating…' : 'Generate buyer-ready listing'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                ),
                if (aiText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: ivory, borderRadius: BorderRadius.circular(14)), child: SelectableText(aiText!)),
                  ),
              ]),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                final p = CraftProduct(
                  id: 'KS-${DateTime.now().millisecondsSinceEpoch % 100000}',
                  name: name.text.trim().isEmpty ? 'Untitled handmade craft' : name.text.trim(),
                  category: category.text,
                  price: double.tryParse(price.text) ?? 0,
                  stock: int.tryParse(capacity.text) ?? 0,
                  description: aiText ?? details.text,
                  story: details.text,
                  materials: materials.text,
                  leadDays: int.tryParse(days.text) ?? 0,
                  photos: photos.map((e) => e.path).toList(),
                );
                DemoData.products.insert(0, p);
                widget.onSaved();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: LText('Product saved in this demo session.')));
              },
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), backgroundColor: olive),
              child: const LText('Save product'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> _getApiKey(String provider) async => _apiKeys['Groq']??'';
final Map<String,String> _apiKeys={'Groq':''};

class ListingPreviewPage extends StatelessWidget{final CraftProduct product;const ListingPreviewPage({super.key,required this.product});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const LText('Buyer preview')),body:PageBody(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[if(product.photos.isNotEmpty)ClipRRect(borderRadius:BorderRadius.circular(20),child:Image.file(File(product.photos.first),height:240,width:double.infinity,fit:BoxFit.cover)),const SizedBox(height:16),LText(product.category.toUpperCase(),style:const TextStyle(color:terracotta,fontWeight:FontWeight.bold,letterSpacing:1.2)),const SizedBox(height:6),LText(product.name,style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900,color:ink)),const SizedBox(height:8),LText('₹${product.price.toStringAsFixed(0)}',style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900,color:olive)),const SizedBox(height:16),panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[sectionTitle('A little story behind it'),LText(product.description),const SizedBox(height:12),const LText('Materials',style:TextStyle(fontWeight:FontWeight.bold)),LText(product.materials.isEmpty?'Not specified':product.materials),const SizedBox(height:12),const LText('Made with care',style:TextStyle(fontWeight:FontWeight.bold)),LText(product.story),const SizedBox(height:12),LText('Made to order: up to ${product.leadDays} days · ${product.stock} units currently listed',style:const TextStyle(color:earth))])),const SizedBox(height:16),FilledButton.icon(onPressed:()=>showShareDialog(context,product),icon:const Icon(Icons.share_outlined),label:const LText('Share listing'))])));}

class OrdersPage extends StatefulWidget{const OrdersPage({super.key});@override State<OrdersPage> createState()=>_OrdersPageState();}
class _OrdersPageState extends State<OrdersPage>{String filter='All';@override Widget build(BuildContext context){final list=DemoData.orders.where((o)=>filter=='All'||o.status==filter).toList();return PageBody(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[heading('Orders','Prepare each craft on time and keep payment status clear.'),DropdownButtonFormField(value:filter,decoration:InputDecoration(labelText: L10n.t('Filter orders')),items:const['All','New','In progress','Ready','Delivered'].map((s)=>DropdownMenuItem(value:s,child:LText(s))).toList(),onChanged:(v)=>setState(()=>filter=v??'All')),const SizedBox(height:14),...list.map((o)=>Padding(padding:const EdgeInsets.only(bottom:12),child:panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:LText(o.id,style:const TextStyle(color:earth,fontWeight:FontWeight.bold))),_status(o.status)]),const SizedBox(height:8),LText(o.product,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:16)),LText('Buyer: ${o.buyer}',style:const TextStyle(color:earth,fontSize:12)),const Divider(height:24),Row(children:[Expanded(child:_orderFact('Quantity','${o.qty} unit(s)')),Expanded(child:_orderFact('Order total','₹${o.total.toStringAsFixed(0)}'))]),const SizedBox(height:12),Row(children:[Expanded(child:_orderFact('Prepare by',o.due)),Expanded(child:Row(children:[Icon(o.paid?Icons.check_circle:Icons.pending,color:o.paid?olive:terracotta,size:17),const SizedBox(width:5),Flexible(child:LText(o.paid?'Paid':'Payment pending',style:TextStyle(color:o.paid?olive:terracotta,fontWeight:FontWeight.bold,fontSize:12)))]))]),const SizedBox(height:12),DropdownButtonFormField<String>(value:o.status,decoration:InputDecoration(labelText: L10n.t('Update order status')),items:const['New','In progress','Ready','Delivered'].map((s)=>DropdownMenuItem(value:s,child:LText(s))).toList(),onChanged:(v){if(v!=null)setState(()=>o.status=v);})]))))]));}}
Widget _orderFact(String label,String value)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LText(label,style:const TextStyle(color:earth,fontSize:11)),const SizedBox(height:3),LText(value,style:const TextStyle(fontWeight:FontWeight.bold))]);

class MarketplacePage extends StatefulWidget{final VoidCallback? onChanged;const MarketplacePage({super.key,this.onChanged});@override State<MarketplacePage> createState()=>_MarketplacePageState();}
class _MarketplacePageState extends State<MarketplacePage>{@override Widget build(BuildContext context)=>PageBody(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[heading('Marketplaces','Choose where you want to offer your craft.'),Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:sand.withOpacity(.35),borderRadius:BorderRadius.circular(16)),child:const Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.info_outline,color:earth),SizedBox(width:10),Expanded(child:LText('Connection and publishing are simulated in this build. Live connections require each marketplace’s seller approval, API access, and credentials.',style:TextStyle(color:earth,fontSize:12)))])),const SizedBox(height:16),...DemoData.marketplaces.map((m)=>Padding(padding:const EdgeInsets.only(bottom:12),child:panel(child:Row(children:[Container(width:48,height:48,decoration:BoxDecoration(color:ivory,borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.storefront_outlined,color:olive)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LText(m.name,style:const TextStyle(fontWeight:FontWeight.w800)),LText(m.subtitle,style:const TextStyle(color:earth,fontSize:11)),const SizedBox(height:6),LText(m.connected?'Connected · demo state':'Not connected',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:m.connected?olive:terracotta))])),if(!m.connected)OutlinedButton(onPressed:()=>setState((){m.connected=true;m.enabled=true;}),child:const LText('Connect demo'))else Switch(value:m.enabled,onChanged:(v)=>setState(()=>m.enabled=v),activeColor:olive)])))),const SizedBox(height:6),sectionTitle('Enabled destinations'),LText('${DemoData.marketplaces.where((m)=>m.connected&&m.enabled).length} marketplace(s) enabled for demo publishing.',style:const TextStyle(color:earth))]));}

class SettingsPage extends StatefulWidget{const SettingsPage({super.key});@override State<SettingsPage> createState()=>_SettingsPageState();}
class _SettingsPageState extends State<SettingsPage>{
 final artisan=TextEditingController(text:'Bharat Wagh'),business=TextEditingController(text:'Bharat Pottery'),phone=TextEditingController(),location=TextEditingController(text:'Pune, Maharashtra'),about=TextEditingController(text:'Small-batch handmade pottery and craft goods.'),groq=TextEditingController();bool showGroq=false;
 @override void initState(){super.initState();groq.text=_apiKeys['Groq']??'';}
 @override void dispose(){artisan.dispose();business.dispose();phone.dispose();location.dispose();about.dispose();groq.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>PageBody(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[heading('Settings','Your artisan profile and AI studio configuration.'),panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[sectionTitle('Language'),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[InputDecorator(decoration:InputDecoration(labelText:L10n.t('Language')),child:DropdownButtonHideUnderline(child:DropdownButton<String>(value:AppLocale.code,isExpanded:true,items:AppLanguages.supported.map((l)=>DropdownMenuItem<String>(value:l.code,enabled:l.code=='en'||l.mlKit!=null,child:Row(children:[Expanded(child:Text(l.nativeName)),if(l.code!='en'&&l.mlKit==null)const LText(' • pack needed',style:TextStyle(fontSize:11,color:earth))]))).toList(),onChanged:(v) async {if(v!=null){await L10n.warmLanguage(v);AppLocale.set(v);setState((){});}}))),const SizedBox(height:6),const LText('Full on-device UI translation is available for 10 Indian languages in this build. The other scheduled languages remain listed for future Indic translation packs.',style:TextStyle(fontSize:11,color:earth))]),const SizedBox(height:14),sectionTitle('Artisan profile'),TextField(controller:artisan,decoration:InputDecoration(labelText:L10n.t('Your name'))),const SizedBox(height:10),TextField(controller:business,decoration:InputDecoration(labelText:L10n.t('Business / craft name'))),const SizedBox(height:10),TextField(controller:phone,keyboardType:TextInputType.phone,decoration:InputDecoration(labelText:L10n.t('Contact number'))),const SizedBox(height:10),TextField(controller:location,decoration:InputDecoration(labelText:L10n.t('Location'))),const SizedBox(height:10),TextField(controller:about,maxLines:3,decoration:InputDecoration(labelText:L10n.t('About your craft / business'))),const SizedBox(height:12),FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:LText('Profile saved for this session.'))),child:const LText('Save profile'))])),const SizedBox(height:14),panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[sectionTitle('AI configuration'),const LText('Groq is the only AI provider used by this build. Your key is kept in app memory for this session.',style:TextStyle(color:earth,fontSize:12)),const SizedBox(height:14),TextField(controller:groq,obscureText:!showGroq,decoration:InputDecoration(labelText:L10n.t('Groq API key'),suffixIcon:IconButton(onPressed:()=>setState(()=>showGroq=!showGroq),icon:Icon(showGroq?Icons.visibility_off:Icons.visibility)))),const SizedBox(height:12),FilledButton(onPressed:(){_apiKeys['Groq']=groq.text.trim();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:LText('AI keys set in memory for this session.')));},child:const LText('Apply API keys'))])),const SizedBox(height:14),panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[sectionTitle('About KaragirSetu'),const LText('Version 2 · SIH prototype build',style:TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:6),const LText('Designed to help artisans tell the story behind their work and manage a growing digital catalog.',style:TextStyle(color:earth)),const SizedBox(height:12),OutlinedButton.icon(onPressed:()=>Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const LoginScreen()),(_)=>false),icon:const Icon(Icons.logout),label:const LText('Log out'))]))]));
}
