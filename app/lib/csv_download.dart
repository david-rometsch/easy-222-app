// routes to web or io implementation at compile time
export 'csv_download_io.dart'
    if (dart.library.html) 'csv_download_web.dart';
