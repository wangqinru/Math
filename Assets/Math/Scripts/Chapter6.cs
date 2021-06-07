using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;

public class Chapter6 : MonoBehaviour
{
	[SerializeField]
	private GameObject cube;
	private bool spinning = true;

	private bool rotating = true;

	private float cubeRotationTime = 0.0f;

	private Quaternion cubeRotationFrom = Quaternion.identity;

	private Quaternion cubeRotationTo = Quaternion.identity;

	private void Update()
	{
		if (spinning)
		{
			Quaternion cubeSpinRoation = Quaternion.AngleAxis(-180.0f, Vector3.left);
			cube.transform.rotation = Quaternion.Slerp(cube.transform.rotation, cubeSpinRoation, 0.05f);
		}

		Quaternion cameraRotation = Quaternion.LookRotation(cube.transform.position + new Vector3(0, 0.5f, 0) - transform.position);

		transform.rotation = Quaternion.Slerp(transform.rotation, cameraRotation, Time.deltaTime);
		transform.Translate(0.02f, 0.005f, 0.5f * Time.deltaTime);

		if (rotating)
		{
			cubeRotationTime += Time.deltaTime / 0.5f;

			cube.transform.rotation = Quaternion.Slerp(cubeRotationFrom, cubeRotationTo, cubeRotationTime);

			if (cubeRotationTime >= 1.0f)
			{
				rotating = false;
				cubeRotationTime = 0.0f;
			}
		}
		else
		{
			if (Input.GetKeyDown(KeyCode.UpArrow))
			{
				ResetCubeRotation(Vector3.right);
				rotating = true;
			}
		}
	}

	private void ResetCubeRotation(Vector3 axis)
	{
		spinning = false;
		cubeRotationFrom = cube.transform.rotation;

		Quaternion q = Quaternion.AngleAxis(90.0f, Quaternion.Inverse(cubeRotationFrom) * axis);

		cubeRotationTo = cubeRotationFrom * q;

		Assert.IsTrue(Quaternion.Inverse(cubeRotationFrom) * axis == cube.transform.InverseTransformVector(axis));
		Assert.AreEqual<Quaternion>(cubeRotationFrom * q, Quaternion.AngleAxis(90.0f,axis) * cubeRotationFrom, null, new QuaternionComparer());
	}

	public class QuaternionComparer : IEqualityComparer<Quaternion>
	{
		public bool Equals(Quaternion lhs, Quaternion rhs) {
			return lhs == rhs;
		}

		public int GetHashCode(Quaternion obj) {
			return obj.GetHashCode();
		}
	}
}
