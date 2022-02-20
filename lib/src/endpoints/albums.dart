// Copyright (c) 2017, rinukkusu. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of spotify;

class Albums extends EndpointPaging {
  late AlbumsMe _me;

  @override
  String get _path => 'v1/albums';

  Albums(SpotifyApiBase api) : super(api) {
    _me = AlbumsMe(api);
  }

  AlbumsMe get me => _me;

  Future<Album> get(String albumId) async {
    var jsonString = await _get('$_path/$albumId');
    var map = json.decode(jsonString);

    return Album.fromJson(map);
  }

  Future<Iterable<Album>> list(Iterable<String> albumIds) async {
    var jsonString = await _get('$_path?ids=${albumIds.join(',')}');
    var map = json.decode(jsonString);
    var artistsMap = map['albums'] as Iterable<dynamic>;
    return artistsMap.map((m) => Album.fromJson(m));
  }

  Pages<TrackSimple> getTracks(String albumId) {
    return _getPages(
        '$_path/$albumId/tracks', (json) => TrackSimple.fromJson(json));
  }
}

class AlbumsMe extends EndpointPaging {
  @override
  String get _path => 'v1/me/albums';

  AlbumsMe(SpotifyApiBase api) : super(api);

  Pages<AlbumSaved> get saved {
    return _getPages(_path, (json) => AlbumSaved.fromJson(json));
  }

  Future<bool> containsOne(String id) async {
    var list = await contains([id]);
    return list.first;
  }

  Future<List<bool>> contains(List<String> ids) async {
    var limit = ids.length < 50 ? ids.length : 50;
    var idsParam = ids.sublist(0, limit).join(',');
    var jsonString = await _api._get('$_path/contains?ids=$idsParam');
    List<bool> list = json.decode(jsonString);
    return list;
  }

  Future<Null> saveOne(String id) {
    return save([id]);
  }

  Future<Null> save(List<String> ids) async {
    var limit = ids.length < 50 ? ids.length : 50;
    var idsParam = ids.sublist(0, limit).join(',');
    await _api._put('$_path?ids=$idsParam', '');
  }
}
