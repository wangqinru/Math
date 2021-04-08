using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Chapter3 : MonoBehaviour
{
    [SerializeField]
    Transform cube;
    
    private List<Vector3> triangleVertices = new List<Vector3>();
    void Start()
    {
        Mesh mesh = cube.gameObject.GetComponent<MeshFilter>().mesh;
        for (int i = 0; i < mesh.vertices.Length; i ++)
        {
            if (triangleVertices.Count < 3)
            {
                triangleVertices.Add(mesh.vertices[i]);
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        DrawCameraLine();
    }

    void DrawCameraLine()
    {
        Debug.DrawLine(cube.position, cube.forward * 2.0f, Color.blue);

        Vector3 cameraPoint = transform.position + transform.forward * 3.0f;

        Vector3 edge1 = triangleVertices[1] - triangleVertices[0];
        Vector3 edge2 = cameraPoint - triangleVertices[1];

        Vector3 edge3 = triangleVertices[2] - triangleVertices[1];
        Vector3 edge4 = cameraPoint - triangleVertices[2];

        Vector3 edge5 = triangleVertices[0] - triangleVertices[2];
        Vector3 edge6 = cameraPoint - triangleVertices[0];

        Vector3 cr1 =  Vector3.Cross(edge1, edge2);
        Vector3 cr2 =  Vector3.Cross(edge3, edge4);
        Vector3 cr3 =  Vector3.Cross(edge5, edge6);

        if (Vector3.Dot(cr1, cr2) > 0 && Vector3.Dot(cr1, cr3) > 0)
        {
            Debug.DrawLine(transform.position, cameraPoint, Color.red);
        }
        else
        {
            Debug.DrawLine(transform.position, cameraPoint, Color.green);
        }
    }
}
