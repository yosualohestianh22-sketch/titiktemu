import urllib.request
import json

titles = [
  "Prambanan",
  "Jalan_Malioboro",
  "Tebing_Breksi",
  "Parangtritis",
  "Kraton_Ngayogyakarta_Hadiningrat",
  "Garuda_Wisnu_Kencana_Cultural_Park",
  "Kuta",
  "Pura_Ulun_Danu_Bratan",
  "National_Monument_(Indonesia)",
  "Dunia_Fantasi",
  "Gili_Trawangan"
]

url = f"https://en.wikipedia.org/w/api.php?action=query&prop=pageimages&titles={'|'.join(titles)}&pithumbsize=800&format=json"

try:
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        pages = data['query']['pages']
        for page_id, page_data in pages.items():
            title = page_data.get('title', '')
            thumb = page_data.get('thumbnail', {}).get('source', 'NO_IMAGE')
            print(f"{title}: {thumb}")
except Exception as e:
    print(f"Error: {e}")
