import 'dart:async';
import 'dart:convert';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:neat_periodic_task/neat_periodic_task.dart';

Products data = [];

typedef Products = List<Product>;

enum ConvenienceStoreName { cu, gs25, emart24 }

// int test2 = 0;
class Product {
  final String id;
  final String title;
  final String price;
  final String src;
  final int size;
  final ConvenienceStoreName convenienceStoreName;
  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.src,
    required this.size,
    required this.convenienceStoreName,
  });
  Map<String, String> json() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'src': src,
      'size': size.toString(),
      'convenienceStoreName': convenienceStoreName.name,
    };
  }
  // String json() {
  //   return '{"id": "$id","title": "$title","price": "$price","src": "$src","size": "${size.toString()}","convenienceStoreName": "${convenienceStoreName.name}"}';
  // }
}

class CrawlerService {
  void setScheduler() {
    print('scheduler 실행');
    final scheduler = NeatPeriodicTaskScheduler(
      interval: const Duration(minutes: 1),
      name: 'crawler',
      minCycle: const Duration(seconds: 2),
      timeout: const Duration(seconds: 30),
      task: () async => fetch(),
    );
    scheduler.start();
  }

  Future<Products?> getGs25() async {
    print('getGs25 시작');
    final Products data = [];
    final url = Uri.parse(
        'http://gs25.gsretail.com/gscvs/ko/products/event-goods-search?pageSize=20&parameterList=ONE_TO_ONE');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Iterable<dynamic> webtoons =
          (jsonDecode(jsonDecode(response.body))['results']
                  as Iterable<dynamic>)
              .where((element) => element['goodsStatNm'] == '정상');
      var i = 0;
      for (final (webtoon) in webtoons) {
        data.add(
          Product(
            id: (++i).toString(),
            title: webtoon['goodsNm'],
            price: webtoon['price'].toString().split('.')[0],
            src: webtoon['attFileNm'],
            size: 2,
            convenienceStoreName: ConvenienceStoreName.gs25,
          ),
        );
      }
      // final box = parse(response.body).querySelectorAll('.prod_box');
      // for (final element in box) {
      //   final reg = RegExp('src="(\\S+)"');
      //   final title = element.querySelector('.tit')?.text.trim();
      //   final price = element.querySelector('.price')?.text.trim();
      //   final src =
      //       reg.firstMatch(element.querySelector('[src]')?.outerHtml ?? '')?[1];

      //   data.add(
      //       {DataKey.title: title, DataKey.price: price, DataKey.src: src});

      //   // data
      //   // ..title = title
      //   // ..price = price
      //   // ..src = src
      // }
      print('getGs25 성공');
      return data;
    }
    print('getGs25 실패');
    return null;
  }

  Future<Products?> getCu() async {
    print('getCu 시작');
    final Products data = [];
    final url = Uri.parse('https://cu.bgfretail.com/event/plusAjax.do');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // final Iterable<dynamic> webtoons =
      //     (jsonDecode(jsonDecode(response.body)) as Iterable<dynamic>);
      // print(webtoons);
      // for (final webtoon in webtoons) {
      //   // print(webtoon['goodsNm']);
      //   data.add({
      //     DataKey.title: webtoon['goodsNm'],
      //     DataKey.price: webtoon['price'].toString(),
      //     DataKey.src: webtoon['attFileNm'],
      //   });
      // }
      final box = parse(response.body).querySelectorAll('.prod_list');
      // print(box);
      var i = 0;
      for (final element in box) {
        final reg = RegExp('src="(\\S+)"');
        final title = element.querySelector('.name')?.text.trim() ?? '';
        final price = element
                .querySelector('.price strong')
                ?.text
                .trim()
                .replaceAll(',', '') ??
            '';
        final src = reg.firstMatch(
                element.querySelector('[src]')?.outerHtml ?? '')?[1] ??
            '';

        data.add(
          Product(
            id: (++i).toString(),
            title: title,
            price: price,
            src: src,
            size: 2,
            convenienceStoreName: ConvenienceStoreName.cu,
          ),
        );

        // data
        // ..title = title
        // ..price = price
        // ..src = src
      }
      print('getCu 성공');
      return data;
    }
    print('getCu 실패');
    return null;
  }

  Future<Products?> getEmart24() async {
    print('getEmart24 시작');
    final Products data = [];
    final url = Uri.parse(
        'https://www.emart24.co.kr/goods/event?search=&category_seq=1&align=');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // final Iterable<dynamic> webtoons =
      //     (jsonDecode(jsonDecode(response.body)) as Iterable<dynamic>);
      // print(webtoons);
      // for (final webtoon in webtoons) {
      //   // print(webtoon['goodsNm']);
      //   data.add({
      //     DataKey.title: webtoon['goodsNm'],
      //     DataKey.price: webtoon['price'].toString(),
      //     DataKey.src: webtoon['attFileNm'],
      //   });
      // }
      final box = parse(response.body).querySelectorAll('.itemWrap');
      // print(box);
      var i = 0;
      for (final element in box) {
        final reg = RegExp('src="(\\S+)"');
        final title = element.querySelector('.itemtitle')?.text.trim() ?? '';
        final price = element
                .querySelector('.itemTxtWrap span')
                ?.text
                .replaceAll('원', '')
                .replaceAll(',', '')
                .trim() ??
            '';
        final src = reg.firstMatch(
                element.querySelector('[src]')?.outerHtml ?? '')?[1] ??
            '';

        data.add(
          Product(
            id: (++i).toString(),
            title: title,
            price: price,
            src: src,
            size: 2,
            convenienceStoreName: ConvenienceStoreName.emart24,
          ),
        );

        // data
        // ..title = title
        // ..price = price
        // ..src = src
      }
      print('getEmart24 성공');
      return data;
    }
    print('getEmart24 실패');
    return null;
  }

  Map<String, dynamic> getData() {
    print('getData 호출');
    // print(data.toString());
    // return '[${data.map((element) => jsonEncode(element.json())).join(',')}]';
    return {
      "data":
          '[${data.map((element) => jsonEncode(element.json())).join(',')}]',
      "updateAt": DateTime.now().toString()
    };
    // return jsonDecode(
    //     '{"data":"[${data.map((element) => jsonEncode(element.json())).join(',')}]", "updateAt": "${DateTime.now()}"}');
  }

  Future<void> fetch() async {
    print('fetch start ${DateTime.now()}');
    final res = await Future.wait([getGs25(), getCu(), 
    //getEmart24()
    ]);
    // print(res);
    for (var item in res) {
      data.addAll(item as Products);
    }
    // print(data);
    print('fetch end ${DateTime.now()}');
  }

  // void test() async {
  //   print(test2);
  //   test2 = test2 + 1;
  // }
}
