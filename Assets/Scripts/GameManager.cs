using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{

    public static GameManager instance;

    public Player player;
    internal bool moveOn = true;

    public bool end = false;

    private void Awake()
    {
        if (instance == null)
            instance = this;
        else Destroy(this);

        //Cursor.lockState = CursorLockMode.locked;
        Cursor.visible = false;
    }

    public Vector3 QuadBezier(Vector3 p0, Vector3 p1, Vector3 p2, float t)
    {
        t = Mathf.Clamp01(t);
        return Mathf.Pow(1f - t, 2f) * p0 + 2f * (1f - t) * t * p1 + Mathf.Pow(t, 2f) * p2;
    }

    private void Update()
    {

    }
}
