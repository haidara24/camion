import 'dart:convert';

import 'package:camion/data/models/post_model.dart';
import 'package:camion/helpers/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostRepository {
  List<Post> posts = [];
  List<SavedPost> savedPosts = [];
  List<Group> groups = [];
  late SharedPreferences prefs;

  Future<List<Post>> getposts() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(POSTS_ENDPOINT, apiToken: jwt);
    posts = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        posts.add(Post.fromJson(element));
      }
    }
    return posts;
  }

  Future<Group?> addGroup(String name) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var jwt = token!.split(".");
    var payload =
        json.decode(ascii.decode(base64.decode(base64.normalize(jwt[1]))));
    var rs = await HttpHelper.post(
        GROUPS_ENDPOINT, {"name": name, "user": payload["user_id"]},
        apiToken: token);
    if (rs.statusCode == 201) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      var group = Group.fromJson(result);
      return group;
    }
    return null;
  }

  Future<SavedPost?> addSavedPost(int post, int group) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var jwt = token!.split(".");
    var payload =
        json.decode(ascii.decode(base64.decode(base64.normalize(jwt[1]))));
    var rs = await HttpHelper.post(
        SAVED_POSTS_ENDPOINT,
        {
          "user": payload["user_id"],
          "post": post,
          "groups": [group]
        },
        apiToken: token);
    if (rs.statusCode == 201) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      var savedpost = SavedPost.fromJson(result);
      return savedpost;
    }
    return null;
  }

  Future<bool> unSavePost(int post) async {
    prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var response = await HttpHelper.delete(
        "${SAVED_POSTS_ENDPOINT}delete/$post/",
        apiToken: token);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<SavedPost>> getsavedPosts(int group) async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get('$SAVED_POSTS_ENDPOINT?groups=$group',
        apiToken: jwt);
    savedPosts = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        savedPosts.add(SavedPost.fromJson(element));
      }
    }
    return savedPosts;
  }

  Future<List<Group>> getgroups() async {
    prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString("token");

    var rs = await HttpHelper.get(GROUPS_ENDPOINT, apiToken: jwt);
    groups = [];
    if (rs.statusCode == 200) {
      var myDataString = utf8.decode(rs.bodyBytes);

      var result = jsonDecode(myDataString);
      for (var element in result) {
        groups.add(Group.fromJson(element));
      }
    }
    return groups;
  }
}
