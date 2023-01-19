from http.server import HTTPServer, BaseHTTPRequestHandler
import json


def get_athlete():
    return {
        "myFavoriteAthlete": "Mahendra Singh Dhoni"
    }



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

    httpd = HTTPServer(('0.0.0.0', 80), APIHandler)
    httpd.serve_forever()

