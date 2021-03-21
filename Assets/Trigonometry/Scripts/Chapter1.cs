using UnityEngine;
using System.Collections.Generic;

public class Chapter1 : MonoBehaviour
{
    [SerializeField, Tooltip("動かすカプセル")]
    private Transform target = null;

    private float targetAngle = 0.0f;

    private float buttonDownTime = 0.0f;

    private List<GameObject> sphereList = new List<GameObject>();
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            buttonDownTime = Time.time;
            Debug.LogFormat("x: {0:f}, y: {1:f}", Input.mousePosition.x, Input.mousePosition.y);

            Vector3 screenPoint = Camera.main.WorldToScreenPoint(target.position);
            Vector3 diff = Input.mousePosition - screenPoint;
            float shita = Mathf.Atan(diff.y / diff.x);
            Debug.LogFormat("Θ : {0:f}", shita * Mathf.Rad2Deg);

            targetAngle = shita * Mathf.Rad2Deg - 90f;

            Vector3 spawnPosition = Input.mousePosition;

            GameObject obj = Instantiate(GameObject.CreatePrimitive(PrimitiveType.Sphere), spawnPosition, Quaternion.identity);
            sphereList.Add(obj);
        }

        if (targetAngle != target.eulerAngles.z) 
        {
            target.eulerAngles = new Vector3(0, 0, Mathf.LerpAngle(target.eulerAngles.z, targetAngle, Time.deltaTime * 5f));
        }

        if (sphereList.Count > 0)
        {
            foreach(var sphere in sphereList)
            {
                sphere.transform.position = new Vector3(
                    sphere.transform.position.x + (target.position.x - sphere.transform.position.x) * Time.deltaTime * 10f,
                    Mathf.Abs(Mathf.Sin((Time.time - buttonDownTime) * Mathf.PI * 2 * 1f) * 3f),
                    0
                );
            }
        }
        
    }
}
