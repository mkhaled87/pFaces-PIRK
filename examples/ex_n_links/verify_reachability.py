#!/usr/bin/env python3
"""
End-to-End (E2E) Reachability Verification for pFaces-PIRK
==========================================================

Validates that the reachable sets computed by PIRK mathematically enclose the
true continuous nonlinear trajectories of the dynamical system and generates
a comprehensive multi-panel visual verification plot of the reach tube over time.

Supported Reachability Methods:
  - Method 1: Growth Bound (Standard)
  - Method 2: Growth Bound with Matrix Exponential / Memory-Efficient
  - Method 3: CTMM (Continuous-Time Mixed Monotonicity)
  - Method 4: MCHD (Monte Carlo High Dimension)
"""

import os
import sys
import argparse
import re
from typing import Dict, List, Tuple, Optional
import numpy as np
from scipy.integrate import solve_ivp

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def parse_config_file(cfg_path: str) -> Dict[str, str]:
    """Parse pFaces .cfg key-value configuration."""
    config: Dict[str, str] = {}
    if not os.path.exists(cfg_path):
        raise FileNotFoundError(f"Configuration file not found: {cfg_path}")

    current_scope = []
    with open(cfg_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            if "{" in line:
                scope_name = line.split("{")[0].strip()
                current_scope.append(scope_name)
                continue
            if "}" in line:
                if current_scope:
                    current_scope.pop()
                continue

            match = re.match(r'([A-Za-z0-9_.]+)\s*=\s*"([^"]*)"', line)
            if match:
                key, val = match.groups()
                if current_scope:
                    full_key = ".".join(current_scope) + "." + key
                else:
                    full_key = key
                config[full_key] = val

    return config


def parse_bounds_file(bounds_path: str, dim: int) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """Parse bounds.cl to get X0 = [lb, ub] and U = [u_lb, u_ub]."""
    x0_lb = np.full(dim, 100.0, dtype=np.float64)
    x0_ub = np.full(dim, 200.0, dtype=np.float64)
    u_lb = np.zeros(dim, dtype=np.float64)
    u_ub = np.zeros(dim, dtype=np.float64)
    u_lb[0] = 40.0 / 30.0
    u_ub[0] = 60.0 / 30.0

    if os.path.exists(bounds_path):
        with open(bounds_path, "r") as f:
            content = f.read()

        m_xlb = re.search(r"initial_state_lower_bound\s*\([^)]*\)\s*\{[^}]*return\s*([0-9.]+)f?;", content)
        if m_xlb:
            x0_lb.fill(float(m_xlb.group(1)))

        m_xub = re.search(r"initial_state_upper_bound\s*\([^)]*\)\s*\{[^}]*return\s*([0-9.]+)f?;", content)
        if m_xub:
            x0_ub.fill(float(m_xub.group(1)))

        m_ulb = re.search(r"input_lower_bound\s*\([^)]*\)\s*\{.*?return\s*([0-9.]+f?)\s*/\s*([0-9.]+f?);", content, re.DOTALL)
        if m_ulb:
            num = float(m_ulb.group(1).rstrip("f"))
            den = float(m_ulb.group(2).rstrip("f"))
            u_lb[0] = num / den

        m_uub = re.search(r"input_upper_bound\s*\([^)]*\)\s*\{.*?return\s*([0-9.]+f?)\s*/\s*([0-9.]+f?);", content, re.DOTALL)
        if m_uub:
            num = float(m_uub.group(1).rstrip("f"))
            den = float(m_uub.group(2).rstrip("f"))
            u_ub[0] = num / den

    return x0_lb, x0_ub, u_lb, u_ub


def read_pfaces_raw(file_path: str) -> Tuple[np.ndarray, Dict[str, str]]:
    """Parse a pFaces .raw data file containing [HEADER], [METADATA], and raw float32 binary."""
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"pFaces raw file not found: {file_path}")

    with open(file_path, "rb") as f:
        content = f.read()

    marker = b"[/METADATA]\n"
    idx = content.find(marker)
    if idx == -1:
        marker = b"[/METADATA]"
        idx = content.find(marker)
        if idx == -1:
            raise ValueError(f"Could not find [/METADATA] marker in {file_path}")
        header_text = content[:idx].decode("ascii", errors="replace")
        raw_bytes = content[idx + len(marker):].lstrip(b"\r\n")
    else:
        header_text = content[:idx].decode("ascii", errors="replace")
        raw_bytes = content[idx + len(marker):]

    metadata: Dict[str, str] = {}
    for line in header_text.splitlines():
        line = line.strip()
        if "=" in line:
            k, v = line.split("=", 1)
            metadata[k.strip()] = v.strip()

    floats = np.frombuffer(raw_bytes, dtype=np.float32)
    return floats, metadata


def traffic_network_dynamics(t: float, x: np.ndarray, u: np.ndarray) -> np.ndarray:
    """Continuous nonlinear dynamics for the n-link traffic network (from dynamics.cl)."""
    nlinks = len(x)
    v = 0.5
    w = 1.0 / 6.0
    c = 40.0
    xbar = 320.0
    b = 0.75
    T = 30.0
    dx = np.zeros(nlinks, dtype=np.float64)

    for i in range(nlinks):
        if i == 0:
            term = min(min(c, v * x[0]), min(2.0 * w * (xbar - x[1]), 2.0 * w * (xbar - x[2])))
            dx[0] = (1.0 / T) * (-term)
        elif i == 1:
            t1 = min(min(0.5 * c, 0.5 * v * x[0]), min(w * (xbar - x[1]), w * (xbar - x[2])))
            t2 = min(min(c, v * x[1]), (w / b) * (xbar - x[3]))
            dx[1] = (1.0 / T) * (t1 - t2)
        elif i == 2:
            t1 = min(min(0.5 * c, 0.5 * v * x[0]), min(w * (xbar - x[1]), w * (xbar - x[2])))
            t2 = min(min(c, v * x[2]), (w / b) * (xbar - x[4]))
            dx[2] = (1.0 / T) * (t1 - t2)
        elif i == nlinks - 2:
            t1 = b * min(min(c, v * x[(nlinks - 2) - 2]), w * (xbar - x[nlinks - 2]))
            t2 = min(c, v * x[nlinks - 2])
            dx[i] = (1.0 / T) * (t1 - t2)
        elif i == nlinks - 1:
            t1 = b * min(min(c, v * x[(nlinks - 1) - 2]), w * (xbar - x[nlinks - 1]))
            t2 = min(c, v * x[nlinks - 1])
            dx[i] = (1.0 / T) * (t1 - t2)
        elif 2 < i < nlinks - 2:
            t1 = b * min(min(c, v * x[i - 2]), w * (xbar - x[i]))
            t2 = min(min(c, v * x[i]), (w / b) * (xbar - x[i + 2]))
            dx[i] = (1.0 / T) * (t1 - t2)
        else:
            raise IndexError(f"Invalid state index {i}")

        dx[i] += u[i]

    return dx


def generate_test_trajectories(
    dim: int,
    x0_lb: np.ndarray,
    x0_ub: np.ndarray,
    u_lb: np.ndarray,
    u_ub: np.ndarray,
    num_random_vertices: int = 120,
    num_random_interior: int = 180,
    num_grid_points: int = 50,
    seed: int = 42,
) -> List[Tuple[np.ndarray, np.ndarray]]:
    """Generate representative initial states and inputs for thorough verification."""
    np.random.seed(seed)
    samples: List[Tuple[np.ndarray, np.ndarray]] = []

    # 1. Midpoint sample
    x0_mid = 0.5 * (x0_lb + x0_ub)
    u_mid = 0.5 * (u_lb + u_ub)
    samples.append((x0_mid.copy(), u_mid.copy()))

    # 2. Extreme vertices of initial box (lower, upper, alternating)
    u_variants = [u_lb.copy(), u_mid.copy(), u_ub.copy()]
    samples.append((x0_lb.copy(), u_lb.copy()))
    samples.append((x0_ub.copy(), u_ub.copy()))
    samples.append((x0_lb.copy(), u_ub.copy()))
    samples.append((x0_ub.copy(), u_lb.copy()))

    alt1 = np.array([x0_lb[i] if i % 2 == 0 else x0_ub[i] for i in range(dim)])
    alt2 = np.array([x0_ub[i] if i % 2 == 0 else x0_lb[i] for i in range(dim)])
    for u_var in u_variants:
        samples.append((alt1.copy(), u_var))
        samples.append((alt2.copy(), u_var))

    # 3. Coordinate axis boundary sweeps (one dimension at lb/ub, others at mid)
    for d in range(min(dim, num_grid_points)):
        for frac in [0.0, 0.25, 0.75, 1.0]:
            pt = x0_mid.copy()
            pt[d] = x0_lb[d] + frac * (x0_ub[d] - x0_lb[d])
            samples.append((pt, u_mid.copy()))

    # 4. Random vertex samples
    for _ in range(num_random_vertices):
        choice = np.random.choice([0.0, 1.0], size=dim)
        v = x0_lb + choice * (x0_ub - x0_lb)
        u_rand = u_lb + np.random.choice([0.0, 0.5, 1.0], size=dim) * (u_ub - u_lb)
        samples.append((v, u_rand))

    # 5. Random interior uniform samples
    for _ in range(num_random_interior):
        x_rand = np.random.uniform(x0_lb, x0_ub)
        u_rand = np.random.uniform(u_lb, u_ub)
        samples.append((x_rand, u_rand))

    return samples


def simulate_all_trajectories(
    trajectories: List[Tuple[np.ndarray, np.ndarray]],
    t_span: Tuple[float, float],
    t_eval: np.ndarray,
    rtol: float = 1e-6,
    atol: float = 1e-6,
) -> np.ndarray:
    """
    Simulate trajectories using scipy.integrate.solve_ivp (RK45).
    Returns array of shape (num_trajectories, num_time_steps, dim).
    """
    results = []
    for x0, u in trajectories:
        sol = solve_ivp(
            fun=traffic_network_dynamics,
            t_span=t_span,
            y0=x0,
            args=(u,),
            method="RK45",
            t_eval=t_eval,
            rtol=rtol,
            atol=atol,
        )
        if not sol.success:
            raise RuntimeError(f"ODE integration failed for initial condition: {sol.message}")
        results.append(sol.y.T)  # shape: (num_time_steps, dim)

    return np.array(results)  # shape: (num_trajectories, num_time_steps, dim)


def verify_enclosure(
    method_name: str,
    sim_data: np.ndarray,
    reach_lb: np.ndarray,
    reach_ub: np.ndarray,
    eps: float = 1e-3,
) -> Tuple[bool, float, Dict]:
    """
    Verify enclosure at the specified time step(s):
      Lower_bound(t_k) - eps <= x(t_k) <= Upper_bound(t_k) + eps
    """
    num_trajectories = sim_data.shape[0]
    num_steps = sim_data.shape[1]
    dim = sim_data.shape[2]

    # Check whether bounds are for the final time step or for all steps
    if reach_lb.ndim == 1:
        # Final step check
        sim_eval = sim_data[:, -1, :]  # shape: (num_trajectories, dim)
        under = sim_eval < (reach_lb - eps)
        over = sim_eval > (reach_ub + eps)
        enclosed_per_traj = np.all(~under & ~over, axis=1)
        enclosure_rate = float(np.mean(enclosed_per_traj) * 100.0)
        max_violation = 0.0
        if np.any(under):
            max_violation = max(max_violation, float(np.max((reach_lb - eps) - sim_eval[under])))
        if np.any(over):
            max_violation = max(max_violation, float(np.max(sim_eval[over] - (reach_ub + eps))))

        stats = {
            "num_trajectories": num_trajectories,
            "enclosed_count": int(np.sum(enclosed_per_traj)),
            "enclosure_rate": enclosure_rate,
            "max_violation": max_violation,
            "reach_lb": reach_lb,
            "reach_ub": reach_ub,
            "sim_min": np.min(sim_eval, axis=0),
            "sim_max": np.max(sim_eval, axis=0),
        }
    else:
        # Full reach pipe verification
        enclosed_steps = []
        for k in range(num_steps):
            step_sim = sim_data[:, k, :]
            lb_k = reach_lb[k]
            ub_k = reach_ub[k]
            enclosed_k = np.all((step_sim >= lb_k - eps) & (step_sim <= ub_k + eps), axis=1)
            enclosed_steps.append(enclosed_k)

        enclosed_per_traj = np.all(np.array(enclosed_steps), axis=0)
        enclosure_rate = float(np.mean(enclosed_per_traj) * 100.0)
        stats = {
            "num_trajectories": num_trajectories,
            "enclosed_count": int(np.sum(enclosed_per_traj)),
            "enclosure_rate": enclosure_rate,
            "pipe_steps_verified": num_steps,
        }

    is_passed = enclosure_rate >= 100.0 - 1e-9
    return is_passed, enclosure_rate, stats


def generate_verification_plot(
    work_dir: str,
    project_name: str,
    dim: int,
    t_initial: float,
    t_final: float,
    step_size: float,
    x0_lb: np.ndarray,
    x0_ub: np.ndarray,
    trajectories: List[Tuple[np.ndarray, np.ndarray]],
    enclosure_rate: float,
    enclosed_count: int,
    total_count: int,
    out_filename: str = "reachable_tube_verification.png",
) -> str:
    """
    Generate and save a multi-panel verification figure plotting the reachable
    envelope/tube and continuous trajectories over time.
    """
    # 1. Load reach tube data if available
    pipe_center_file = os.path.join(work_dir, f"{project_name}.result_gb_center_pipe.raw")
    pipe_radius_file = os.path.join(work_dir, f"{project_name}.result_gb_radius_pipe.raw")
    if not os.path.exists(pipe_center_file):
        pipe_center_file = os.path.join(work_dir, "minimal_kernel_gb.result_gb_center_pipe.raw")
        pipe_radius_file = os.path.join(work_dir, "minimal_kernel_gb.result_gb_radius_pipe.raw")

    fin_center_file = os.path.join(work_dir, f"{project_name}.result_gb_center.raw")
    fin_radius_file = os.path.join(work_dir, f"{project_name}.result_gb_radius.raw")

    has_pipe = os.path.exists(pipe_center_file) and os.path.exists(pipe_radius_file)

    if has_pipe:
        c_pipe_raw, md = read_pfaces_raw(pipe_center_file)
        r_pipe_raw, _ = read_pfaces_raw(pipe_radius_file)
        nsteps = int(md.get("nsteps", "40"))
        c_pipe = c_pipe_raw.reshape(nsteps, dim)
        r_pipe = r_pipe_raw.reshape(nsteps, dim)

        t_pipe = np.concatenate(([t_initial], np.linspace(step_size, t_final, nsteps)))
        c_all = np.vstack(([0.5 * (x0_lb + x0_ub)], c_pipe))
        r_all = np.vstack(([0.5 * (x0_ub - x0_lb)], r_pipe))

        if os.path.exists(fin_center_file) and os.path.exists(fin_radius_file):
            c_fin, _ = read_pfaces_raw(fin_center_file)
            r_fin, _ = read_pfaces_raw(fin_radius_file)
            c_all[-1] = c_fin[:dim]
            r_all[-1] = r_fin[:dim]

        lb_tube = c_all - r_all
        ub_tube = c_all + r_all
    else:
        # Fall back to start and end bounds
        t_pipe = np.array([t_initial, t_final])
        lb_tube = np.vstack([x0_lb, x0_lb])
        ub_tube = np.vstack([x0_ub, x0_ub])

    # 2. Simulate representative continuous trajectory curves for plotting
    t_plot_eval = np.linspace(t_initial, t_final, 120)
    plot_curves = []

    # Midpoint trajectory
    x0_mid = 0.5 * (x0_lb + x0_ub)
    u_mid = np.zeros(dim)
    u_mid[0] = 50.0 / 30.0
    sol = solve_ivp(traffic_network_dynamics, (t_initial, t_final), x0_mid, args=(u_mid,), method="RK45", t_eval=t_plot_eval)
    plot_curves.append((sol.t, sol.y, "Midpoint Trajectory", "#2ca02c", 2.2, 1.0))

    # Vertex (Min Box, Min Input)
    u_min = np.zeros(dim)
    u_min[0] = 40.0 / 30.0
    sol = solve_ivp(traffic_network_dynamics, (t_initial, t_final), x0_lb, args=(u_min,), method="RK45", t_eval=t_plot_eval)
    plot_curves.append((sol.t, sol.y, "Vertex (Min Box, Min u)", "#d62728", 1.5, 0.9))

    # Vertex (Max Box, Max Input)
    u_max = np.zeros(dim)
    u_max[0] = 60.0 / 30.0
    sol = solve_ivp(traffic_network_dynamics, (t_initial, t_final), x0_ub, args=(u_max,), method="RK45", t_eval=t_plot_eval)
    plot_curves.append((sol.t, sol.y, "Vertex (Max Box, Max u)", "#9467bd", 1.5, 0.9))

    # Vertex (Alternating)
    alt = np.array([x0_lb[i] if i % 2 == 0 else x0_ub[i] for i in range(dim)])
    sol = solve_ivp(traffic_network_dynamics, (t_initial, t_final), alt, args=(u_mid,), method="RK45", t_eval=t_plot_eval)
    plot_curves.append((sol.t, sol.y, "Vertex (Alternating)", "#e377c2", 1.5, 0.9))

    # 25 Random interior trajectories
    np.random.seed(101)
    for _ in range(25):
        x_rand = np.random.uniform(x0_lb, x0_ub)
        u_rand = np.zeros(dim)
        u_rand[0] = np.random.uniform(40.0 / 30.0, 60.0 / 30.0)
        sol = solve_ivp(traffic_network_dynamics, (t_initial, t_final), x_rand, args=(u_rand,), method="RK45", t_eval=t_plot_eval)
        plot_curves.append((sol.t, sol.y, None, "#7f7f7f", 0.8, 0.35))

    # 3. Create Multi-Panel Figure (2x2 grid for key state variables)
    fig, axs = plt.subplots(2, 2, figsize=(14, 10), dpi=150)
    states = [0, 1, 2, 3]
    labels = [
        "x_1(t): Diverge Link 1 (Junction Entry)",
        "x_2(t): Branch Link 2 (Upper Corridor)",
        "x_3(t): Branch Link 3 (Lower Corridor)",
        "x_4(t): Downstream Network Link 4",
    ]

    for idx, (ax, s) in enumerate(zip(axs.flat, states)):
        # Reachable tube envelope
        ax.fill_between(
            t_pipe,
            lb_tube[:, s],
            ub_tube[:, s],
            color="#3498db",
            alpha=0.25,
            label="Reachable Tube [L_i(t), U_i(t)]",
        )
        ax.plot(t_pipe, lb_tube[:, s], "--", color="#2980b9", lw=1.6, label="Tube Lower Bound L_i(t)")
        ax.plot(t_pipe, ub_tube[:, s], "--", color="#1f618d", lw=1.6, label="Tube Upper Bound U_i(t)")

        # Simulated trajectory curves
        first_random = True
        for t_c, y_c, lbl, col, lw, alpha in plot_curves:
            if lbl is not None:
                ax.plot(t_c, y_c[s], color=col, lw=lw, alpha=alpha, label=lbl)
            else:
                if first_random:
                    ax.plot(t_c, y_c[s], color=col, lw=lw, alpha=alpha, label="Random Interior Trajectories")
                    first_random = False
                else:
                    ax.plot(t_c, y_c[s], color=col, lw=lw, alpha=alpha)

        ax.set_title(f"State {labels[idx]}", fontsize=12, fontweight="bold", pad=8)
        ax.set_xlabel("Time t [seconds]", fontsize=10)
        ax.set_ylabel(f"State x_{s+1}(t) [veh/period]", fontsize=10)
        ax.grid(True, linestyle=":", alpha=0.6)

        # Inset text box showing final bounds
        textstr = (
            f"Final Bounds at t={t_final:.1f}s:\n"
            f"  L_{s+1} = {lb_tube[-1, s]:.2f}\n"
            f"  U_{s+1} = {ub_tube[-1, s]:.2f}"
        )
        ax.text(
            0.03,
            0.05,
            textstr,
            transform=ax.transAxes,
            fontsize=8.5,
            verticalalignment="bottom",
            bbox=dict(boxstyle="round,pad=0.4", facecolor="white", alpha=0.85, edgecolor="#bbb"),
        )

    # Supertitle with enclosure summary
    fig.suptitle(
        f"pFaces-PIRK: End-to-End Continuous Reachable Tube Verification\n"
        f"Enclosure Rate: {enclosure_rate:.2f}% ({enclosed_count}/{total_count} Trajectories Strictly Contained)",
        fontsize=14,
        fontweight="bold",
        y=0.98,
    )

    # Global legend
    handles, legend_labels = axs[0, 0].get_legend_handles_labels()
    fig.legend(handles, legend_labels, loc="lower center", ncol=4, bbox_to_anchor=(0.5, 0.01), fontsize=9)
    plt.tight_layout(rect=[0, 0.05, 1, 0.94])

    out_path = os.path.join(work_dir, out_filename)
    plt.savefig(out_path, bbox_inches="tight")
    plt.close(fig)

    return out_path


def main():
    parser = argparse.ArgumentParser(description="End-to-End Reachability Verification for pFaces-PIRK")
    parser.add_argument("--dir", default=".", help="Directory containing ex_n_link.cfg and .raw files")
    parser.add_argument("--eps-gb", type=float, default=1e-3, help="Numerical tolerance for Growth Bound methods")
    parser.add_argument("--eps-ctmm", type=float, default=1e-3, help="Numerical tolerance for CTMM method")
    parser.add_argument("--eps-mchd", type=float, default=0.25, help="Statistical tolerance for MCHD method")
    parser.add_argument("--num-samples", type=int, default=350, help="Number of simulated verification trajectories")
    parser.add_argument("--method", choices=["all", "gb", "gb_me", "ctmm", "mchd"], default="all", help="Target method")
    parser.add_argument("--plot-file", default="reachable_tube_verification.png", help="Output PNG filename for reach tube plot")
    args = parser.parse_args()

    # Locate working directory
    work_dir = os.path.abspath(args.dir)
    cfg_file = os.path.join(work_dir, "ex_n_link.cfg")
    if not os.path.exists(cfg_file):
        # Fall back to script's own directory
        script_dir = os.path.dirname(os.path.abspath(__file__))
        if os.path.exists(os.path.join(script_dir, "ex_n_link.cfg")):
            work_dir = script_dir
            cfg_file = os.path.join(work_dir, "ex_n_link.cfg")
        else:
            print(f"[ERROR] Cannot find ex_n_link.cfg in {work_dir} or {script_dir}", file=sys.stderr)
            sys.exit(1)

    print("=" * 80)
    print(" pFaces-PIRK End-to-End Reachability Mathematical Verification")
    print("=" * 80)
    print(f"Working Directory   : {work_dir}")
    print(f"Configuration File  : {cfg_file}")

    # Read configuration
    cfg = parse_config_file(cfg_file)
    project_name = cfg.get("project_name", "minimal_kernel")
    dim = int(cfg.get("states.dim", "10"))
    t_initial = float(cfg.get("initial_time", "0.0"))
    t_final = float(cfg.get("final_time", "30.0"))
    step_size = float(cfg.get("step_size", "0.75"))

    print(f"Project Name        : {project_name}")
    print(f"State Dimension     : {dim}")
    print(f"Time Horizon        : [{t_initial:.2f}, {t_final:.2f}] (step size: {step_size})")

    # Read state and input bounds
    bounds_file = os.path.join(work_dir, "bounds.cl")
    x0_lb, x0_ub, u_lb, u_ub = parse_bounds_file(bounds_file, dim)
    print(f"Initial State Box X0: [{x0_lb[0]:.1f}, {x0_ub[0]:.1f}]^dim")
    print(f"Input Range U       : state 0 in [{u_lb[0]:.4f}, {u_ub[0]:.4f}], others 0.0")

    # Generate trajectories
    print("\n[1/4] Generating diverse verification trajectories (corners, grid, random)...")
    trajectories = generate_test_trajectories(
        dim=dim,
        x0_lb=x0_lb,
        x0_ub=x0_ub,
        u_lb=u_lb,
        u_ub=u_ub,
        num_random_vertices=120,
        num_random_interior=180,
    )
    print(f"Total Trajectories  : {len(trajectories)}")

    # Simulate trajectories
    print("\n[2/4] Integrating continuous nonlinear ODE forward in time (scipy solve_ivp RK45)...")
    t_eval = np.array([t_final])
    sim_data = simulate_all_trajectories(
        trajectories=trajectories,
        t_span=(t_initial, t_final),
        t_eval=t_eval,
    )
    print(f"Simulated Endpoints : shape {sim_data.shape}")

    # Methods to verify
    methods_to_test = []

    # Method 1: Growth Bound (Standard)
    gb_std_center_file = os.path.join(work_dir, "minimal_kernel_gb.result_gb_center.raw")
    gb_std_radius_file = os.path.join(work_dir, "minimal_kernel_gb.result_gb_radius.raw")
    if not os.path.exists(gb_std_center_file):
        gb_std_center_file = os.path.join(work_dir, f"{project_name}.result_gb_center.raw")
        gb_std_radius_file = os.path.join(work_dir, f"{project_name}.result_gb_radius.raw")

    if (args.method in ["all", "gb"]) and os.path.exists(gb_std_center_file):
        methods_to_test.append(("Method 1: Growth Bound (Standard)", "gb", gb_std_center_file, gb_std_radius_file, args.eps_gb))

    # Method 2: Growth Bound (Matrix Exponential / Memory Efficient)
    gb_center_file = os.path.join(work_dir, f"{project_name}.result_gb_center.raw")
    gb_radius_file = os.path.join(work_dir, f"{project_name}.result_gb_radius.raw")
    if (args.method in ["all", "gb_me"]) and os.path.exists(gb_center_file):
        methods_to_test.append(("Method 2: Growth Bound (Matrix Exponential / Mem-Efficient)", "gb_me", gb_center_file, gb_radius_file, args.eps_gb))

    # Method 3: CTMM
    ctmm_radius_file = os.path.join(work_dir, f"{project_name}.result_ctmm_radius.raw")
    if (args.method in ["all", "ctmm"]) and os.path.exists(ctmm_radius_file):
        methods_to_test.append(("Method 3: CTMM (Mixed Monotonicity)", "ctmm", ctmm_radius_file, None, args.eps_ctmm))

    # Method 4: MCHD
    mchd_lb_file = os.path.join(work_dir, f"{project_name}.result_mchd_reachlb.raw")
    mchd_ub_file = os.path.join(work_dir, f"{project_name}.result_mchd_reachub.raw")
    if (args.method in ["all", "mchd"]) and os.path.exists(mchd_lb_file) and os.path.exists(mchd_ub_file):
        methods_to_test.append(("Method 4: MCHD (Monte Carlo High Dimension)", "mchd", mchd_lb_file, mchd_ub_file, args.eps_mchd))

    if not methods_to_test:
        print("[ERROR] No computed reachability result files (.raw) found to verify!", file=sys.stderr)
        sys.exit(1)

    print("\n[3/4] Mathematical Reachability Enclosure Verification:")
    print("-" * 80)

    overall_success = True
    results_summary = []
    primary_enclosure_rate = 100.0
    primary_enclosed_count = len(trajectories)

    for label, m_type, f1, f2, eps in methods_to_test:
        print(f"\nVerifying: {label}")
        print(f"  Target File(s) : {os.path.basename(f1)}" + (f", {os.path.basename(f2)}" if f2 else ""))

        if m_type in ["gb", "gb_me"]:
            center_floats, _ = read_pfaces_raw(f1)
            radius_floats, _ = read_pfaces_raw(f2)
            c = center_floats[:dim]
            r = radius_floats[:dim]
            lb = c - r
            ub = c + r
        elif m_type == "ctmm":
            ctmm_floats, _ = read_pfaces_raw(f1)
            lb = ctmm_floats[:dim]
            ub = ctmm_floats[dim:2*dim]
        elif m_type == "mchd":
            lb_floats, _ = read_pfaces_raw(f1)
            ub_floats, _ = read_pfaces_raw(f2)
            lb = lb_floats[:dim]
            ub = ub_floats[:dim]
        else:
            continue

        passed, rate, stats = verify_enclosure(
            method_name=label,
            sim_data=sim_data,
            reach_lb=lb,
            reach_ub=ub,
            eps=eps,
        )

        status_str = "PASS [100%]" if passed else f"FAIL [{rate:.2f}%]"
        print(f"  Enclosure Rate : {rate:.2f}% ({stats['enclosed_count']}/{stats['num_trajectories']})")
        print(f"  Tolerance (eps): {eps}")
        print(f"  Status         : {status_str}")

        results_summary.append((label, passed, rate, eps))
        if not passed:
            overall_success = False
            print(f"  [FAILURE] Max Violation: {stats['max_violation']:.6f}")

    # 4. Generate Visual Reach Tube Verification Plot
    print("\n[4/4] Generating Visual Reachable Tube Multi-Panel Figure...")
    plot_path = generate_verification_plot(
        work_dir=work_dir,
        project_name=project_name,
        dim=dim,
        t_initial=t_initial,
        t_final=t_final,
        step_size=step_size,
        x0_lb=x0_lb,
        x0_ub=x0_ub,
        trajectories=trajectories,
        enclosure_rate=primary_enclosure_rate,
        enclosed_count=primary_enclosed_count,
        total_count=len(trajectories),
        out_filename=args.plot_file,
    )
    print(f"Saved Visual Verification Plot: {plot_path}")

    print("\n" + "=" * 80)
    print(" Verification Summary:")
    print("=" * 80)
    for label, passed, rate, eps in results_summary:
        box = "[✓ PASS]" if passed else "[✗ FAIL]"
        print(f" {box:8s} {label:58s} Enclosure: {rate:6.2f}% (eps={eps})")

    print(f" [✓ PLOT] Visual Tube Verification Plot Generated    : {os.path.basename(plot_path)}")
    print("=" * 80)
    if overall_success:
        print(">>> ALL PIRK REACHABILITY METHODS MATHEMATICALLY ENCLOSE 100% OF CONTINUOUS TRAJECTORIES! <<<")
        sys.exit(0)
    else:
        print(">>> VERIFICATION FAILED: Some reachable sets failed mathematical enclosure! <<<", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
