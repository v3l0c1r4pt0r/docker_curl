#include <curl/curl.h>

int main() {
  CURL *curl;
  CURLcode res;
  curl = curl_easy_init();
  curl_easy_cleanup(curl);
  return res;
}
