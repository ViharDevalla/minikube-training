from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import sys
import os


def get_athlete():
    return {
        "myFavoriteAthlete": "Mahendra Singh Dhoni"
    }


PORT = 80

if(len(sys.argv)>1):
    if(sys.argv[1] in ["--test","-t"]):
        PORT = 3000

class APIHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/athlete':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            data = get_athlete()
            self.wfile.write(json.dumps(data).encode())
        else:
            self.send_response(404)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'error': 'Not Found'}).encode())


if __name__ == '__main__':
    print(os.getpid())
    httpd = HTTPServer(('0.0.0.0', PORT), APIHandler)
    httpd.serve_forever()

