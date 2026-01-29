import React, { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { Users, Plus, Edit2, Trash2, DollarSign } from 'lucide-react';

interface Employee {
  id: string;
  profile_id: string | null;
  name: string;
  email: string;
  commission_rate: number;
  employee_type: string;
  active: boolean;
  hired_at: string;
  created_at: string;
}

export default function EmployeeManagement() {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddModal, setShowAddModal] = useState(false);
  const [editingEmployee, setEditingEmployee] = useState<Employee | null>(null);

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    commission_rate: 0.50,
    employee_type: 'sales',
    active: true,
  });

  useEffect(() => {
    loadEmployees();
  }, []);

  async function loadEmployees() {
    try {
      const { data } = await supabase
        .from('employee_reps')
        .select('*')
        .order('created_at', { ascending: false });

      setEmployees(data || []);
    } catch (error) {
      console.error('Error loading employees:', error);
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();

    try {
      if (editingEmployee) {
        await supabase
          .from('employee_reps')
          .update(formData)
          .eq('id', editingEmployee.id);
      } else {
        await supabase
          .from('employee_reps')
          .insert([formData]);
      }

      await loadEmployees();
      resetForm();
    } catch (error) {
      console.error('Error saving employee:', error);
    }
  }

  async function deleteEmployee(id: string) {
    if (!confirm('Are you sure you want to delete this employee?')) return;

    try {
      await supabase
        .from('employee_reps')
        .delete()
        .eq('id', id);

      await loadEmployees();
    } catch (error) {
      console.error('Error deleting employee:', error);
    }
  }

  function resetForm() {
    setFormData({
      name: '',
      email: '',
      commission_rate: 0.50,
      employee_type: 'sales',
      active: true,
    });
    setShowAddModal(false);
    setEditingEmployee(null);
  }

  function startEdit(employee: Employee) {
    setEditingEmployee(employee);
    setFormData({
      name: employee.name,
      email: employee.email,
      commission_rate: employee.commission_rate,
      employee_type: employee.employee_type,
      active: employee.active,
    });
    setShowAddModal(true);
  }

  const activeEmployees = employees.filter(e => e.active);
  const inactiveEmployees = employees.filter(e => !e.active);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Employee Management</h1>
          <p className="text-gray-600">Manage your team and commission rates</p>
        </div>
        <button
          onClick={() => setShowAddModal(true)}
          className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          <Plus className="h-5 w-5" />
          Add Employee
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Employees</p>
              <p className="text-3xl font-bold text-gray-900">{employees.length}</p>
            </div>
            <Users className="h-10 w-10 text-blue-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6 border border-green-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Active</p>
              <p className="text-3xl font-bold text-gray-900">{activeEmployees.length}</p>
            </div>
            <Users className="h-10 w-10 text-green-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6 border border-orange-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Default Rate</p>
              <p className="text-3xl font-bold text-gray-900">50%</p>
            </div>
            <DollarSign className="h-10 w-10 text-orange-500" />
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <div className="p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">Active Employees</h2>
          {activeEmployees.length === 0 ? (
            <p className="text-gray-500 text-center py-8">No active employees</p>
          ) : (
            <div className="space-y-4">
              {activeEmployees.map(employee => (
                <div key={employee.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50">
                  <div className="flex-1">
                    <h3 className="font-semibold text-gray-900">{employee.name}</h3>
                    <p className="text-sm text-gray-600">{employee.email}</p>
                    <div className="flex items-center gap-4 mt-2">
                      <span className="text-xs px-2 py-1 bg-blue-100 text-blue-700 rounded">
                        {employee.employee_type}
                      </span>
                      <span className="text-xs text-gray-600">
                        Commission: {(employee.commission_rate * 100).toFixed(0)}%
                      </span>
                      <span className="text-xs text-gray-600">
                        Hired: {new Date(employee.hired_at).toLocaleDateString()}
                      </span>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => startEdit(employee)}
                      className="p-2 text-blue-600 hover:bg-blue-50 rounded"
                    >
                      <Edit2 className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => deleteEmployee(employee.id)}
                      className="p-2 text-red-600 hover:bg-red-50 rounded"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {inactiveEmployees.length > 0 && (
          <div className="p-6 border-t border-gray-200">
            <h2 className="text-xl font-bold text-gray-900 mb-4">Inactive Employees</h2>
            <div className="space-y-4">
              {inactiveEmployees.map(employee => (
                <div key={employee.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg bg-gray-50">
                  <div className="flex-1 opacity-60">
                    <h3 className="font-semibold text-gray-900">{employee.name}</h3>
                    <p className="text-sm text-gray-600">{employee.email}</p>
                    <div className="flex items-center gap-4 mt-2">
                      <span className="text-xs px-2 py-1 bg-gray-200 text-gray-700 rounded">
                        {employee.employee_type}
                      </span>
                      <span className="text-xs text-gray-600">
                        Commission: {(employee.commission_rate * 100).toFixed(0)}%
                      </span>
                    </div>
                  </div>
                  <button
                    onClick={() => startEdit(employee)}
                    className="p-2 text-blue-600 hover:bg-blue-50 rounded"
                  >
                    <Edit2 className="h-4 w-4" />
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {showAddModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-8 max-w-md w-full">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">
              {editingEmployee ? 'Edit Employee' : 'Add New Employee'}
            </h2>
            <form onSubmit={handleSubmit}>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Name
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Email
                  </label>
                  <input
                    type="email"
                    required
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Employee Type
                  </label>
                  <select
                    value={formData.employee_type}
                    onChange={(e) => setFormData({ ...formData, employee_type: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                  >
                    <option value="sales">Sales</option>
                    <option value="support">Support</option>
                    <option value="developer">Developer</option>
                    <option value="marketing">Marketing</option>
                    <option value="manager">Manager</option>
                    <option value="other">Other</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Commission Rate (%)
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    max="1"
                    value={formData.commission_rate}
                    onChange={(e) => setFormData({ ...formData, commission_rate: parseFloat(e.target.value) })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                  />
                  <p className="text-sm text-gray-500 mt-1">
                    Enter as decimal (0.50 = 50%)
                  </p>
                </div>

                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    checked={formData.active}
                    onChange={(e) => setFormData({ ...formData, active: e.target.checked })}
                    className="w-4 h-4"
                  />
                  <label className="text-sm font-medium text-gray-700">
                    Active Employee
                  </label>
                </div>
              </div>

              <div className="flex gap-4 mt-6">
                <button
                  type="button"
                  onClick={resetForm}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                >
                  {editingEmployee ? 'Update' : 'Add Employee'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
