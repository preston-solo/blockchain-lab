import hashlib
import time

def mine_block(data: str, difficulty: int) -> dict:
    prefix = "0" * difficulty
    nonce = 0
    start = time.time()
    
    while True:
        candidate = f"{data}{nonce}"
        h = hashlib.sha256(candidate.encode()).hexdigest()
        if h.startswith(prefix):
            elapsed = time.time() - start
            return {"nonce": nonce, "hash": h, "time": elapsed}
        nonce += 1

print("--- Mining with Difficulty 3 ---")
result3 = mine_block("SSBlock#1", difficulty=3)
print(f"Nonce: {result3['nonce']}")
print(f"Hash:  {result3['hash']}")
print(f"Time:  {result3['time']:.3f}s")

print("\n--- Mining with Difficulty 5 ---")
result5 = mine_block("SSBlock#1", difficulty=5)
print(f"Nonce: {result5['nonce']}")
print(f"Hash:  {result5['hash']}")
print(f"Time:  {result5['time']:.3f}s")
