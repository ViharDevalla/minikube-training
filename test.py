import unittest
from unittest.mock import Mock

import server

import json
from urllib.request import urlopen
from urllib.error import URLError, HTTPError


class TestingAthlete(unittest.TestCase):
    def test_athlete_function(self):
        self.assertEqual(server.get_athlete(), {'myFavoriteAthlete': 'Mahendra Singh Dhoni'},"Logic Function is working")

    def mock_test_athlete_function(self):
        server = Mock()
        server.get_athlete.return_value = {'myFavoriteAthlete': 'Mahendra Singh Dhoni'}
        self.assertEqual(server.get_athlete(), {'myFavoriteAthlete': 'Mahendra Singh Dhoni'},"Mock Function is working")

    def test_athlete_api_success(self):
        with urlopen("http://localhost/athlete") as response:
            self.assertEqual(response.code, 200, "Status Code is Correct")
            self.assertEqual(response.headers['Content-Type'], 'application/json',"JSON Header is Correct")
            self.assertEqual(json.loads(response.read()), {'myFavoriteAthlete': 'Mahendra Singh Dhoni'},"Response is Valid")

    def test_athlete_api_fail(self):
        # Testing a non-existent endpoint
        try:
            req = urlopen("http://localhost")
        except HTTPError as e:
            self.assertEqual(e.code, 404, "404 Error is correct")
            self.assertEqual(e.headers['Content-Type'], 'application/json',"JSON Header is Correct")
            self.assertEqual(json.loads(e.read()), {'error': 'Not Found'},"Response is Valid for non-endpoints")
        except URLError as e:
            self.fail("Server not found")
        except Exception as e:
            self.fail("Unexpected error: {}".format(e))




if __name__ == '__main__':
    unittest.main()