import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/data/models/post_model.dart';
import 'package:sq_connect/app/data/models/user_model.dart';
import 'package:sq_connect/app/data/repositories/post_repository.dart';
import 'package:sq_connect/app/data/repositories/user_repository.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart';

enum SearchFilter { all, users, posts }

class SearchUserController extends GetxController {
  final UserRepository _userRepository;
  final PostRepository _postRepository;

  SearchUserController({required UserRepository userRepository, required PostRepository postRepository})
      : _userRepository = userRepository,
        _postRepository = postRepository;

  final TextEditingController searchTec = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<User> userResults = <User>[].obs;
  final RxList<Post> postResults = <Post>[].obs;

  final Rx<SearchFilter> currentFilter = SearchFilter.all.obs;

  // Debounce search to avoid too many API calls
  Worker? _debounceWorker;

  @override
  void onInit() {
    super.onInit();
    _debounceWorker = debounce(searchQuery, (_) => performSearch(),
        time: const Duration(milliseconds: 700));
    searchTec.addListener(() {
      searchQuery.value = searchTec.text.trim();
    });
  }

  void changeFilter(SearchFilter filter) {
    currentFilter.value = filter;
    // Re-run search with the new filter if query is not empty
    if (searchQuery.value.isNotEmpty) {
      performSearch(clearPrevious: true);
    } else {
      // Clear results if query is empty and filter changes
      userResults.clear();
      postResults.clear();
    }
  }

  Future<void> performSearch({bool clearPrevious = true}) async {
    if (searchQuery.value.length < 2 && searchQuery.value.isNotEmpty) { // Minimum query length
      // UIHelpers.showInfoSnackbar("Type at least 2 characters to search.");
      return;
    }
    if (searchQuery.value.isEmpty) {
      userResults.clear();
      postResults.clear();
      errorMessage.value = '';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    if (clearPrevious) {
      userResults.clear();
      postResults.clear();
    }

    try {
      if (currentFilter.value == SearchFilter.all || currentFilter.value == SearchFilter.users) {
        final userResponse = await _userRepository.searchUsers(searchQuery.value); // Assuming this method exists
        if (userResponse.success && userResponse.data != null) {
          userResults.assignAll(userResponse.data!);
        } else if (!userResponse.success) {
          errorMessage.value += "\nUser search: ${userResponse.message}";
        }
      }
      if (currentFilter.value == SearchFilter.all || currentFilter.value == SearchFilter.posts) {
        final postResponse = await _postRepository.searchPosts(searchQuery.value); // Assuming this method exists
        if (postResponse.success && postResponse.data != null) {
          postResults.assignAll(postResponse.data!);
        } else if (!postResponse.success) {
          errorMessage.value += "\nPost search: ${postResponse.message}";
        }
      }
    } catch (e) {
      errorMessage.value = "Search error: ${e.toString()}";
      UIHelpers.showErrorSnackbar("Search failed.");
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
     searchTec.clear();
     searchQuery.value = ''; // This will trigger debounced performSearch which clears results
  }


  @override
  void onClose() {
    _debounceWorker?.dispose();
    searchTec.dispose();
    super.onClose();
  }
}