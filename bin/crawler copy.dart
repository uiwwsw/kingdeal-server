import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
// import 'package:neat_periodic_task/neat_periodic_task.dart';

enum DataKey { id, title, price, src }

enum ConvenienceStoreKey { gs25, cu, emart24 }

typedef ConvenienceStore = List<Map<String, String?>>;
typedef Data = Map<String, ConvenienceStore?>;

class CrawlerService {
  File file = File('convenienceData.json');

  // CrawlerService() {
  //   // final scheduler = NeatPeriodicTaskScheduler(
  //   //   interval: const Duration(hours: 1),
  //   //   name: 'crawler',
  //   //   timeout: const Duration(seconds: 5),
  //   //   task: () async => init(),
  //   // );
  //   init();
  //   // scheduler.start();
  // }
  Future<ConvenienceStore?> getGs25() async {
    final ConvenienceStore data = [];
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
        data.add({
          DataKey.id.name: (++i).toString(),
          DataKey.title.name: webtoon['goodsNm'],
          DataKey.price.name: webtoon['price'].toString().split('.')[0],
          DataKey.src.name: webtoon['attFileNm'],
        });
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
      return data;
    }
    return null;
  }

  Future<ConvenienceStore?> getCu() async {
    final ConvenienceStore data = [];
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
        final title = element.querySelector('.name')?.text.trim();
        final price = element
            .querySelector('.price strong')
            ?.text
            .trim()
            .replaceAll(',', '');
        final src =
            reg.firstMatch(element.querySelector('[src]')?.outerHtml ?? '')?[1];

        data.add({
          DataKey.id.name: (++i).toString(),
          DataKey.title.name: title,
          DataKey.price.name: price,
          DataKey.src.name: src
        });

        // data
        // ..title = title
        // ..price = price
        // ..src = src
      }
      return data;
    }
    return null;
  }

  Future<ConvenienceStore?> getEmart24() async {
    final ConvenienceStore data = [];
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
        final title = element.querySelector('.itemtitle')?.text.trim();
        final price = element
            .querySelector('.itemTxtWrap span')
            ?.text
            .replaceAll('원', '')
            .replaceAll(',', '')
            .trim();
        final src =
            reg.firstMatch(element.querySelector('[src]')?.outerHtml ?? '')?[1];

        data.add({
          DataKey.id.name: (++i).toString(),
          DataKey.title.name: title,
          DataKey.price.name: price,
          DataKey.src.name: src
        });

        // data
        // ..title = title
        // ..price = price
        // ..src = src
      }
      return data;
    }
    return null;
  }

  Future<Data> getData() async {
    final Data data = {
      ConvenienceStoreKey.gs25.name: await getGs25(),
      ConvenienceStoreKey.cu.name: await getCu(),
      ConvenienceStoreKey.emart24.name: await getEmart24()
    };
    // print(data);
    return data;
  }
}

// void main() {
//   CrawlerService().init();
// }
