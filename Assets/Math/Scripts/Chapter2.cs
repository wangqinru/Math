using UnityEngine;

/// <summary>
/// this script will be attach by camera
/// </summary>
public class Chapter2 : MonoBehaviour
{
    // Start is called before the first frame update

    [SerializeField]
    private Transform target = null;

    [SerializeField]
    /// <summary>
    /// 仰角 (ラジアン)
    /// </summary>
    float _elevation = 90f;

    [SerializeField]
    /// <summary>
    /// 方位角（ラジアン）
    /// </summary>
    float _azimuth = 180f;

    [SerializeField]
    /// <summary>
    /// カメラの距離
    /// </summary>
    float _distance = 5f;

    float rotateSpeed = 100f;
	float scrollSpeed = 200f;

    float maxDistance = 10.0f;

    float minDistance = 3.0f;

    float minAzimuth = 0f;
    float maxAzimuth = 360f;
	float minElevation = 0f;
	float maxElevation = 90f;

    public float distance
    { 
        get { return _distance; }
        private set
        {
            _distance = Mathf.Clamp( value, minDistance, maxDistance );
        }
    }

    public float azimuth
    { 
        get { return _azimuth; }
        private set
        { 
            _azimuth = Mathf.Repeat( value, maxAzimuth - minAzimuth ); 
        }
    }

    public float elevation
    { 
        get{ return _elevation; }
        private set
        { 
            _elevation = Mathf.Clamp( value, minElevation, maxElevation ); 
        }
    }
    
    public Vector2 Rotate(float newAzimuth, float newElevation)
    {
        azimuth += newAzimuth;
        elevation += newElevation;
        return new Vector2(azimuth, elevation);
	}
		
    public float TranslateDistance(float x) {
        distance += x;
        return distance;
    }

    void Start()
    {
        distance = transform.position.magnitude;
        elevation = Mathf.Acos(transform.position.y / distance);
        azimuth = Mathf.Atan(transform.position.z / transform.position.x);
    }

    // Update is called once per frame
    void Update()
    {
        float kh, kv, mh, mv, h, v;
		kh = Input.GetAxis( "Horizontal" );
		kv = Input.GetAxis( "Vertical" );
		
		bool anyMouseButton = Input.GetMouseButton(0) | Input.GetMouseButton(1) | Input.GetMouseButton(2);
		mh = anyMouseButton ? Input.GetAxis( "Mouse X" ) : 0f;
		mv = anyMouseButton ? Input.GetAxis( "Mouse Y" ) : 0f;
		
		h = kh * kh > mh * mh ? kh : mh;
		v = kv * kv > mv * mv ? kv : mv;
		
		if (h * h > Mathf.Epsilon || v * v > Mathf.Epsilon) 
        {   
            Vector2 newAngle = Rotate(h * rotateSpeed * Time.deltaTime, v * rotateSpeed * Time.deltaTime);
            
            azimuth = newAngle.x;
            elevation = newAngle.y;
            // Debug.LogFormat("azimuth : {0}, elevation : {1}", azimuth, elevation);
        }

        float sw = -Input.GetAxis("Mouse ScrollWheel");
		if (sw * sw > Mathf.Epsilon) {
            distance = TranslateDistance(sw * Time.deltaTime * scrollSpeed);
        }

        transform.position = CalcCameraPosition(azimuth * Mathf.Deg2Rad, elevation * Mathf.Deg2Rad, distance, target.position);

        transform.LookAt(target);
    }

    Vector3 CalcCameraPosition(float azi, float eve, float dist, Vector3 center)
    {
        float positionY = dist * Mathf.Cos(eve);
        float positionX = dist * Mathf.Sin(eve) * Mathf.Cos(azi);
        float positionZ = dist * Mathf.Sin(eve) * Mathf.Sin(azi);

        return center + new Vector3(positionX, positionY, positionZ);
    }
}
